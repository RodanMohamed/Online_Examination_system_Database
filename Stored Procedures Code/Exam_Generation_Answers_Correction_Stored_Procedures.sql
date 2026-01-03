
-- ////////////////////////////////////////////////////////////// Exam Generation

------------------------------------------------------------------
-- Generate Exam
CREATE PROC Generate_Exam
(
    @CourseName VARCHAR(100),
    @ExamDate DATE,
    @StartTime TIME(7),
    @EndTime TIME(7),
    @TotalMCQQuestions INT,
    @TotalTrueFalseQuestions INT
)
AS
BEGIN
    DECLARE 
        @CourseID INT,
        @ExamID INT,
        @AvailableMCQ INT,
        @AvailableTF INT,
        @TotalGrade DECIMAL(5,2);

    -- 1. Get Course ID
    SELECT @CourseID = CourseID
    FROM Course
    WHERE CourseName = @CourseName;

    IF @CourseID IS NULL
    BEGIN
        RAISERROR('Course not found', 16, 1);
        RETURN;
    END;

    -- 2. Check course has questions
    IF NOT EXISTS (
        SELECT 1
        FROM Question
        WHERE CourseID = @CourseID
    )
    BEGIN
        RAISERROR('Not enough questions found for this course', 16, 1);
        RETURN;
    END;

    -- 3. Count available questions
    SELECT @AvailableMCQ = COUNT(*)
    FROM Question
    WHERE CourseID = @CourseID AND QuestionType = 'M';

    SELECT @AvailableTF = COUNT(*)
    FROM Question
    WHERE CourseID = @CourseID AND QuestionType = 'T';

    -- 4. Validate requested counts
    IF @TotalMCQQuestions > @AvailableMCQ
    BEGIN
        RAISERROR('Not enough MCQ questions. Available: %d', 16, 1, @AvailableMCQ);
        RETURN;
    END;

    IF @TotalTrueFalseQuestions > @AvailableTF
    BEGIN
        RAISERROR('Not enough True/False questions. Available: %d', 16, 1, @AvailableTF);
        RETURN;
    END;

    -- 5. Select random questions
    DECLARE @SelectedQuestions TABLE
    (
        RowNum INT IDENTITY(1,1),
        QuestionID INT,
        QuestionMark DECIMAL(5,2)
    );

    -- Random MCQ
    INSERT INTO @SelectedQuestions (QuestionID, QuestionMark)
    SELECT TOP (@TotalMCQQuestions)
           QuestionID,
           QuestionMark
    FROM Question
    WHERE CourseID = @CourseID AND QuestionType = 'M'
    ORDER BY NEWID();

    -- Random True/False
    INSERT INTO @SelectedQuestions (QuestionID, QuestionMark)
    SELECT TOP (@TotalTrueFalseQuestions)
           QuestionID,
           QuestionMark
    FROM Question
    WHERE CourseID = @CourseID AND QuestionType = 'T'
    ORDER BY NEWID();

    -- 6. Calculate Total Grade
    SELECT @TotalGrade = SUM(QuestionMark)
    FROM @SelectedQuestions;

    -- 7. Insert Exam and get ExamID
    EXEC AddExam
        @ExamDate = @ExamDate,
        @StartTime = @StartTime,
        @EndTime = @EndTime,
        @TotalMCQQuestions = @TotalMCQQuestions,
        @TotalTrueFalseQuestions = @TotalTrueFalseQuestions,
        @TotalGrade = @TotalGrade,
        @ExamID = @ExamID OUTPUT;  -- capture ExamID

    -- 8. Insert Exam Questions
    DECLARE @QuestionID INT,
            @QuestionOrder INT = 1;

    DECLARE ExamCursor CURSOR FOR
        SELECT QuestionID
        FROM @SelectedQuestions
        ORDER BY RowNum;

    OPEN ExamCursor;
    FETCH NEXT FROM ExamCursor INTO @QuestionID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC AddExamQuestion
            @ExamId = @ExamID,
            @QuestionId = @QuestionID,
            @QuestionOrder = @QuestionOrder;

        SET @QuestionOrder += 1;
        FETCH NEXT FROM ExamCursor INTO @QuestionID;
    END;

    CLOSE ExamCursor;
    DEALLOCATE ExamCursor;

END;
GO



-- ////////////////////////////////////////////////////////////// Student Exam Answers

-- there is already a table by the name of "dbo.Student_Answer" and has its get stored procedure " EXEC GetAnswersByStudentIDAndExamID 2,6 "
-- it gets the questions that the student has answered and his/her choice but the problem is it also shows whether the answer is right or wrong
-- and the degree he/she got by answering that question , so here is a SP that gets the same data but without the correction part


-- Student answers WITHOUT correction 
CREATE PROCEDURE Student_Exam_Answers
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    --SET NOCOUNT ON;

    DECLARE @StudentExamID INT;

    --1. Check Student exists
    IF NOT EXISTS (
        SELECT 1 FROM Student WHERE StudentID = @StudentID
    )
        THROW 50001, 'Student does not exist.', 1;

    --2. Check Exam exists
    IF NOT EXISTS (
        SELECT 1 FROM Exam WHERE ExamID = @ExamID
    )
        THROW 50002, 'Exam does not exist.', 1;

    --3. Get StudentExamID
    SELECT @StudentExamID = StudentExamID
    FROM Student_Exam
    WHERE StudentID = @StudentID
      AND ExamID = @ExamID;

    IF @StudentExamID IS NULL
        THROW 50003, 'Student is not registered for this exam.', 1;

    --4. Check answers exist
    IF NOT EXISTS (
        SELECT 1 FROM Student_Answer WHERE StudentExamID = @StudentExamID
    )
        THROW 50004, 'No answers recorded for this exam.', 1;

    --5. Return answers WITHOUT correction
    SELECT
        sa.StudentAnswerID,
        q.QuestionID,
        q.QuestionText,
        ch.ChoiceID,
        ch.ChoiceLabel,
        ch.ChoiceText
    FROM Student_Answer sa
        JOIN Question q ON sa.QuestionID = q.QuestionID 
        LEFT JOIN Choice ch ON sa.AnswerID = ch.ChoiceID 
    WHERE sa.StudentExamID = @StudentExamID
    ORDER BY q.QuestionID;
END;
GO


---------------------------------------------------------------------------------------------------

-- Student answers WITH correct choice info and correctness
CREATE PROCEDURE Student_Exam_Answers_with_Correct_Choices
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StudentExamID INT;

    --1. Check Student exists
    IF NOT EXISTS (
        SELECT 1 FROM Student WHERE StudentID = @StudentID
    )
        THROW 50001, 'Student does not exist.', 1;

    --2. Check Exam exists
    IF NOT EXISTS (
        SELECT 1 FROM Exam WHERE ExamID = @ExamID
    )
        THROW 50002, 'Exam does not exist.', 1;

    --3. Get StudentExamID
    SELECT @StudentExamID = StudentExamID
    FROM Student_Exam
    WHERE StudentID = @StudentID
      AND ExamID = @ExamID;

    IF @StudentExamID IS NULL
        THROW 50003, 'Student is not registered for this exam.', 1;

    --4. Check answers exist
    IF NOT EXISTS (
        SELECT 1 FROM Student_Answer WHERE StudentExamID = @StudentExamID
    )
        THROW 50004, 'No answers recorded for this exam.', 1;

    --5. Return answers with correctness and correct choice info
    SELECT
        sa.StudentAnswerID,
        q.QuestionID,
        q.QuestionText,
        sa.AnswerID AS StudentChoiceID,
        ch.ChoiceLabel AS StudentChoiceLabel,
        ch.ChoiceText AS StudentChoiceText,
        CASE 
            WHEN sa.IsCorrect = 1 THEN 'Correct'
            WHEN sa.IsCorrect = 0 THEN 'Not Correct'
            ELSE 'Not Answered'
        END AS [Is Correct Answer],
        cc.ChoiceID AS CorrectChoiceID,
        cc.ChoiceLabel AS CorrectChoiceLabel,
        cc.ChoiceText AS CorrectChoiceText
    FROM Student_Answer sa
        JOIN Question q ON sa.QuestionID = q.QuestionID
        LEFT JOIN Choice ch ON sa.AnswerID = ch.ChoiceID
        LEFT JOIN Choice cc ON cc.QuestionID = q.QuestionID AND cc.IsCorrectChoice = 1
    WHERE sa.StudentExamID = @StudentExamID
    ORDER BY q.QuestionID;
END;
GO




-- ////////////////////////////////////////////////////////////// Exam Correction


-- Final exam correction procedure
CREATE PROCEDURE Student_Exam_Correction
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    --SET NOCOUNT ON;

    DECLARE 
        @StudentExamID INT,
        @TotalScore DECIMAL(5,2),
        @Percentage DECIMAL(5,2),
        @TotalGrade DECIMAL(5,2),
        @StudentEndTime DATETIME,
        @Now DATETIME = GETDATE();

    ---------------------------------------------------
    -- 1. Validate Student exists
    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
        THROW 50001, 'Student does not exist.', 1;

    ---------------------------------------------------
    -- 2. Validate Exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamID = @ExamID)
        THROW 50002, 'Exam does not exist.', 1;

    ---------------------------------------------------
    -- 3. Get StudentExamID & EndTime
    SELECT 
        @StudentExamID = StudentExamID,
        @StudentEndTime = EndTime
    FROM Student_Exam
    WHERE StudentID = @StudentID
      AND ExamID = @ExamID;

    IF @StudentExamID IS NULL
        THROW 50003, 'Student did not take this exam.', 1;

    ---------------------------------------------------
    -- 4. Validate answers exist
    IF NOT EXISTS (
        SELECT 1 
        FROM Student_Answer 
        WHERE StudentExamID = @StudentExamID
    )
        THROW 50004, 'No answers found for this student exam.', 1;

    ---------------------------------------------------
    -- 5. Get exam total grade
    SELECT @TotalGrade = TotalGrade
    FROM Exam
    WHERE ExamID = @ExamID;

    IF @TotalGrade = 0
        THROW 50005, 'Exam total grade is zero. Correction not possible.', 1;

    ---------------------------------------------------
    -- 6. CASE 1: Exam NOT finished yet
    /*IF @Now <= @StudentEndTime
    BEGIN
        SELECT 
            'Student has not finished answering yet' AS Message;
        RETURN;
    END;*/

    ---------------------------------------------------
    -- 7. CASE 2: Correct exam (only once)
    IF EXISTS (
        SELECT 1
        FROM Student_Exam
        WHERE StudentExamID = @StudentExamID
          AND TotalScore IS NULL
          AND Percentage IS NULL
    )
    BEGIN
        SELECT @TotalScore = SUM(ISNULL(Mark, 0))
        FROM Student_Answer
        WHERE StudentExamID = @StudentExamID;

        SET @Percentage = (@TotalScore / @TotalGrade) * 100;

        UPDATE Student_Exam
        SET 
            TotalScore = @TotalScore,
            Percentage = @Percentage
        WHERE StudentExamID = @StudentExamID;
    END;

    ---------------------------------------------------
    -- 8. CASE 3: Display result (already corrected)
    SELECT
        c.CourseName,
        s.FirstName + ' ' + s.LastName AS StudentName,
        e.ExamID,
        e.TotalGrade AS [Exam Total Grade],
        se.TotalScore AS [Student Score],
        se.Percentage
    FROM Student_Exam se
        JOIN Student s ON se.StudentID = s.StudentID
        JOIN Exam e ON se.ExamID = e.ExamID
        JOIN Exam_Question eq ON e.ExamID = eq.ExamID
        JOIN Question q ON eq.QuestionID = q.QuestionID
        JOIN Course c ON q.CourseID = c.CourseID
    WHERE se.StudentExamID = @StudentExamID
    GROUP BY 
        c.CourseName,
        s.FirstName,
        s.LastName,
        e.ExamID,
        e.TotalGrade,
        se.TotalScore,
        se.Percentage;
END;
GO







-- ///////////////////////////////////////////////////////////////// Extra Get_Exam_Correct_Answers (model_answer)

-- Get correct answers for an exam
CREATE PROCEDURE Get_Exam_Correct_Answers
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;

    --1. Validate Exam exists
    IF NOT EXISTS (
        SELECT 1 FROM Exam WHERE ExamID = @ExamID
    )
        THROW 50001, 'Exam does not exist.', 1;

    --2. Validate exam has questions
    IF NOT EXISTS (
        SELECT 1 FROM Exam_Question WHERE ExamID = @ExamID
    )
        THROW 50002, 'This exam has no questions assigned.', 1;

    --3. Return course, questions, and correct answers
    SELECT
        e.ExamID,
        c.CourseName,
        q.QuestionID,
        q.QuestionText,
        CASE 
            WHEN q.QuestionType = 'M' THEN 'MCQ'
            WHEN q.QuestionType = 'T' THEN 'T/F'
            ELSE q.QuestionType
        END AS [QuestionType],
        ch.ChoiceID AS [Correct Choice ID],
        ch.ChoiceLabel AS [Correct Choice Label],
        ch.ChoiceText AS [Correct Choice Text]
    FROM Exam_Question eq
        JOIN Exam e ON eq.ExamID = e.ExamID
        JOIN Question q ON eq.QuestionID = q.QuestionID
        JOIN Course c ON q.CourseID = c.CourseID
        JOIN Choice ch ON ch.QuestionID = q.QuestionID
    WHERE eq.ExamID = @ExamID
      AND ch.IsCorrectChoice = 1
    ORDER BY eq.QuestionOrder;
END;
GO

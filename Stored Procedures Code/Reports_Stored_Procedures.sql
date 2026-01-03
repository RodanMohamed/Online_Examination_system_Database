
--1. Report that returns the students information according to Department No parameter. (TrackID)
CREATE PROCEDURE GetStudentByTrack
       @TrackID INT
AS
BEGIN
 IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackID = @TrackID)
    BEGIN
        RAISERROR('Track is not found', 16, 1);
        RETURN;
    END
SELECT *
    FROM Student
    WHERE TrackID = @TrackID;
END;
GO

------------------------------------------------------------------------------------------------------------------------------

--2. Report that takes the student ID and returns the grades of the student in all courses they had an exam on. (StudentID)
create procedure StudentGradesReport
	@StudentId int
as
begin
	-- Check if student exists
	if not exists(select 1 from Student where StudentID = @StudentId)
	begin
		raiserror('Student does not exist.', 16, 1);
	return;
	end


	--Check if student has taken any exams
	if not exists(select 1 from Student_Exam where StudentID = @StudentId)
	begin
		 raiserror('Student has not taken any exams yet.', 16 ,1);
		 return;
	end

	SELECT
        c.CourseName,
        s.FirstName + ' ' + s.LastName AS StudentName,
        e.ExamID,
        e.ExamDate,
        e.TotalGrade AS [Exam Total Grade],
        se.TotalScore AS [Student Score],
        se.Percentage,
        CASE
            WHEN se.TotalScore IS NULL AND se.Percentage IS NULL
                THEN 'Student exam has not been corrected yet'
            ELSE 'Corrected'
        END AS [Exam Status]
    FROM Student_Exam se
        JOIN Student s ON se.StudentID = s.StudentID
        JOIN Exam e ON se.ExamID = e.ExamID
        JOIN Exam_Question eq ON e.ExamID = eq.ExamID
        JOIN Question q ON eq.QuestionID = q.QuestionID
        JOIN Course c ON q.CourseID = c.CourseID
    WHERE se.StudentId = @StudentId
    GROUP BY 
        c.CourseName,
        s.FirstName,
        s.LastName,
        e.ExamID,
        e.ExamDate,
        e.TotalGrade,
        se.TotalScore,
        se.Percentage;
end
go

-------------------------------------------------------------------------------------------------------------------------------------

--3. Report that takes the instructor ID and returns the name of the courses that he teaches and the number of student per course. (InstructorID)
CREATE PROCEDURE GetCoursesAndStudentsByInstID
    @InstID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = @InstID)
        RAISERROR('Instructor is not found', 16, 1);

    SELECT 
        c.CourseID,
        c.CourseName,
        COUNT(DISTINCT s.StudentID) AS [Num Of Students]
    FROM Instructor_Course ic
    JOIN Course c ON ic.CourseID = c.CourseID
    LEFT JOIN Track_Course tc ON c.CourseID = tc.CourseID
    LEFT JOIN Student s ON tc.TrackID = s.TrackID
    WHERE ic.InstructorID = @InstID
    GROUP BY c.CourseID, c.CourseName;

END;
GO

--------------------------------------------------------------------------------------------------------------------------------------

--4. Report that takes course ID and returns its topics. (CourseID) (one of the CRUD operations of table Course_Topic)
CREATE PROCEDURE GetTopicsByCourseId
    @CourseId INT
AS
BEGIN
    --SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseId)
        THROW 50001, 'Course does not exist.', 1;

    IF NOT EXISTS (SELECT 1 FROM Course_Topic WHERE CourseID = @CourseId)
        THROW 50002, 'No topics assigned to this course.', 1;

    SELECT 
        c.CourseName,
        t.TopicID,
        t.TopicName
    FROM Topic t
    JOIN Course_Topic ct ON t.TopicID = ct.TopicID
    JOIN Course c ON ct.CourseID = c.CourseID
    WHERE c.CourseID = @CourseID
    ORDER BY c.CourseName;

END;
GO

-------------------------------------------------------------------------------------------------------------------------------------

--5. Report that takes exam number and returns the Questions in it and choices. (ExamID)
create procedure GetExamQuestionsWithChoicesReport
	@ExamId int
as
begin
	-- Check if exam exists
	if not exists(
	select 1
	from Exam
	where ExamID = @ExamId)
	begin
		 raiserror('Exam does not exist.', 16, 1);
		 return;
	end

	-- Check if exam has questions
	if not exists(
	select 1
	from Exam_Question
	where ExamID = @ExamId)
	begin
		raiserror('Exam has no questions.', 16, 1);
	return;
	end

	-- Get questions with choices
	select q.QuestionID,q.QuestionType,q.QuestionText,c.ChoiceID,c.ChoiceLabel,c.ChoiceText
	from Exam_Question eq
	join Question q on eq.QuestionID = q.QuestionID
	join choice c on c.QuestionID = q.QuestionID
	where eq.ExamID = @ExamId
end;
go

-----------------------------------------------------------------------------------------------------------------------------------------

--6. Report that takes exam number and the student ID then returns the Questions in this exam with the student answers. (StudentID , ExamID)

-- option 1 : Exam Student Answers without correct choices.
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



-- option 2 :Exam Student Answers with correct choices.
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
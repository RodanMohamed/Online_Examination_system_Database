-- ///////////////////////////////////////////////////////SELECT

------------------------------------------------- Branch Track

--1. Get all Branch-Track details with supervisor name
CREATE PROCEDURE GetAllBranchesTracksDetails
AS
BEGIN
    -- Optional: check if there are any records
    IF NOT EXISTS (SELECT 1 FROM Branch_Track)
    BEGIN
        RAISERROR('No Branch-Track records found', 16, 1);
        RETURN;
    END

    SELECT 
        b.BranchName,
        b.BranchLocation,
        t.TrackName,
        CONCAT(i.FirstName, ' ', i.LastName) AS TrackSupervisorName
    FROM Branch_Track bt
    INNER JOIN Branch b ON bt.BranchID = b.BranchID
    INNER JOIN Track t ON bt.TrackID = t.TrackID
    LEFT JOIN Instructor i ON t.TrackSupervisor = i.InstructorID
END
GO

-- Example call
-- EXEC GetAllBranchTrackDetails


--2. Select Tracks by Branch with supervisor name
CREATE PROCEDURE GetBranchTracksDetailsById
    @BranchID INT
AS
BEGIN
    -- 1. Check if the branch exists
    IF NOT EXISTS (SELECT 1 FROM Branch WHERE BranchID = @BranchID)
    BEGIN
        RAISERROR('Branch does not exist', 16, 1);
        RETURN;
    END

    -- 2. Check if there are tracks for this branch
    IF NOT EXISTS (SELECT 1 FROM Branch_Track WHERE BranchID = @BranchID)
    BEGIN
        RAISERROR('No tracks found for this branch', 16, 1);
        RETURN;
    END

    -- 3. Select the tracks with proper joins
    SELECT 
        b.BranchName,
        b.BranchLocation,
        t.TrackName,
        CONCAT(i.FirstName, ' ', i.LastName) AS TrackSupervisorName
    FROM Branch_Track bt
    INNER JOIN Branch b ON bt.BranchID = b.BranchID
    INNER JOIN Track t ON bt.TrackID = t.TrackID
    LEFT JOIN Instructor i ON t.TrackSupervisor = i.InstructorID
    WHERE bt.BranchID = @BranchID
END
GO

-- Example call
-- EXEC GetBranchTracksDetailsById 99



--3. Select Branches by TrackID
CREATE PROCEDURE GetTrackBranchesDetailsById
    @TrackId INT
AS
BEGIN
    -- 1. Validate track exists
    IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackID = @TrackId)
    BEGIN
        RAISERROR('Track does not exist', 16, 1);
        RETURN;
    END

    -- 2. Validate track is assigned to at least one branch
    IF NOT EXISTS (SELECT 1 FROM Branch_Track WHERE TrackID = @TrackId)
    BEGIN
        RAISERROR('This track is not assigned to any branch yet', 16, 1);
        RETURN;
    END

    -- 3. Select branches for this track
    SELECT 
        t.TrackName,
        b.BranchName,
        b.BranchLocation
    FROM Branch_Track bt
    INNER JOIN Branch b ON bt.BranchID = b.BranchID
    INNER JOIN Track t ON bt.TrackID = t.TrackID
    WHERE bt.TrackID = @TrackId;
END
GO

-- Example call
-- EXEC GetTrackBranchesDetailsById 3;



--------------------------------------------------- Track-Instructor

--1. Select all track-instructor records with instructor full name
CREATE PROCEDURE GetAllTrackInstructorsDetails
AS
BEGIN
    -- 1. Validate that there are records
    IF NOT EXISTS (SELECT 1 FROM Track_Instructor)
    BEGIN
        RAISERROR('No Track-Instructor records found', 16, 1);
        RETURN;
    END

    -- 2. Select records with instructor full name
    SELECT 
        ti.TrackInstructorID,
        t.TrackID,
        t.TrackName,
        i.InstructorID,
        i.FirstName + ' ' + i.LastName AS InstructorName
    FROM Track_Instructor ti
    INNER JOIN Track t ON ti.TrackID = t.TrackID
    INNER JOIN Instructor i ON ti.InstructorID = i.InstructorID;
END
GO

-- Example call
-- EXEC GetAllTrackInstructorsDetails;



--2. Select instructors by TrackID

CREATE PROCEDURE GetInstructorsByTrackId
    @TrackId INT
AS
BEGIN
    -- 1. Validate that the track exists
    IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackID = @TrackId)
    BEGIN
        RAISERROR('Track does not exist', 16, 1);
        RETURN;
    END

    -- 2. Validate that the track has instructors
    IF NOT EXISTS (SELECT 1 FROM Track_Instructor WHERE TrackID = @TrackId)
    BEGIN
        RAISERROR('No instructors assigned to this track', 16, 1);
        RETURN;
    END

    -- 3. Select instructors for the track
    SELECT 
        ti.InstructorID,
        i.FirstName + ' ' + i.LastName AS InstructorName
    FROM Track_Instructor ti
    INNER JOIN Instructor i ON ti.InstructorID = i.InstructorID
    WHERE ti.TrackID = @TrackId;
END
GO

-- Example call
-- EXEC GetInstructorsByTrackId 9;



--3. Select Tracks by InstructorID
CREATE PROCEDURE GetTracksByInstructorId
    @InsId INT
AS
BEGIN
    -- 1. Validate that the instructor exists
    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = @InsId)
    BEGIN
        RAISERROR('Instructor does not exist', 16, 1);
        RETURN;
    END

    -- 2. Validate that the instructor is assigned to tracks
    IF NOT EXISTS (SELECT 1 FROM Track_Instructor WHERE InstructorID = @InsId)
    BEGIN
        RAISERROR('This instructor is not assigned to any track yet', 16, 1);
        RETURN;
    END

    -- 3. Select tracks assigned to this instructor
    SELECT 
        i.FirstName + ' ' + i.LastName AS InstructorName,
        t.TrackID,
        t.TrackName
    FROM Track_Instructor ti
    INNER JOIN Track t ON ti.TrackID = t.TrackID
    INNER JOIN Instructor i ON ti.InstructorID = i.InstructorID
    WHERE ti.InstructorID = @InsId;
END
GO

-- Example call:
-- EXEC GetTracksByInstructorId 200;

------------------------------------------------- track course

--1. Get all Track-Course details
CREATE PROCEDURE GetAllTracksCoursesDetails
AS
BEGIN
    --2. Check if there are any records in Track_Course
    IF NOT EXISTS (SELECT 1 FROM Track_Course)
    BEGIN
        RAISERROR('No Track-Course records found', 16, 1);
        RETURN;
    END

    --3. Select Track-Course details with names
    SELECT 
        tc.TrackCourseID,
        t.TrackName,
        c.CourseName
    FROM Track_Course tc
    INNER JOIN Track t ON tc.TrackID = t.TrackID
    INNER JOIN Course c ON tc.CourseID = c.CourseID;
END
GO

-- Example call:
-- EXEC GetAllTracksCoursesDetails;



--2. Get courses by TrackID
CREATE PROCEDURE GetCoursesByTrackId 
    @TrackID INT
AS
BEGIN
    --1. Validate that the Track exists
    IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackID = @TrackID)
    BEGIN
        RAISERROR('Track does not exist', 16, 1);
        RETURN;
    END

    --2. Check if any courses are assigned to this Track
    IF NOT EXISTS (SELECT 1 FROM Track_Course WHERE TrackID = @TrackID)
    BEGIN
        RAISERROR('No courses assigned to this track', 16, 1);
        RETURN;
    END

    --3. Select Track-Course details
    SELECT 
        tc.TrackCourseID,
        c.CourseName
    FROM Track_Course tc
    INNER JOIN Course c ON tc.CourseID = c.CourseID
    WHERE tc.TrackID = @TrackID;
END
GO

-- Example call:
-- EXEC GetCoursesByTrackId 199;



--3. Get Tracks by CourseID
CREATE PROCEDURE GetTracksByCourseId
    @CourseID INT
AS
BEGIN
    --2. Validate that the Course exists
    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseID)
    BEGIN
        RAISERROR('Course does not exist', 16, 1);
        RETURN;
    END

    --3. Check if any tracks are assigned to this Course
    IF NOT EXISTS (SELECT 1 FROM Track_Course WHERE CourseID = @CourseID)
    BEGIN
        RAISERROR('This course is not assigned to any track', 16, 1);
        RETURN;
    END

    --4. Select Track-Course details
    SELECT 
        c.CourseName,
        t.TrackID,
        t.TrackName
    FROM Track_Course tc
    INNER JOIN Track t ON tc.TrackID = t.TrackID
    INNER JOIN Course c ON tc.CourseID = c.CourseID
    WHERE tc.CourseID = @CourseID;
END
GO

-- Example call:
-- EXEC GetTracksByCourseId 4;


----------------------------------------Instructor Course

--1. Get all Instructor-Course details
CREATE PROCEDURE GetAllInstructorsCoursesDetails
AS
BEGIN
    --1.1 Check if any records exist
    IF NOT EXISTS (SELECT 1 FROM Instructor_Course)
    BEGIN
        RAISERROR('No Instructor-Course records found', 16, 1);
        RETURN;
    END

    --1.2 Select all instructor-course details
    SELECT 
        ic.InstructorCourseID,
        i.FirstName + ' ' + i.LastName AS InstructorName,
        c.CourseName
    FROM Instructor_Course ic
    INNER JOIN Instructor i ON ic.InstructorID = i.InstructorID
    INNER JOIN Course c ON ic.CourseID = c.CourseID;
END
GO

-- Example call:
-- EXEC GetAllInstructorsCoursesDetails;


--2. Get courses by InstructorID
CREATE PROCEDURE GetCoursesByInstructorId
    @InstructorID INT
AS
BEGIN
    --2.1 Validate instructor exists
    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = @InstructorID)
    BEGIN
        RAISERROR('Instructor does not exist', 16, 1);
        RETURN;
    END

    --2.2 Validate instructor has assigned courses
    IF NOT EXISTS (SELECT 1 FROM Instructor_Course WHERE InstructorID = @InstructorID)
    BEGIN
        RAISERROR('No courses assigned to this instructor', 16, 1);
        RETURN;
    END

    --2.3 Select courses assigned to instructor
    SELECT 
        c.CourseID,
        c.CourseName
    FROM Instructor_Course ic
    INNER JOIN Course c ON ic.CourseID = c.CourseID
    WHERE ic.InstructorID = @InstructorID;
END
GO

-- Example call:
-- EXEC GetCoursesByInstructorId 99;


--3. Get instructors by CourseID
CREATE PROCEDURE GetInstructorsByCourseId
    @CourseID INT
AS
BEGIN
    --3.1 Validate course exists
    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseID)
    BEGIN
        RAISERROR('Course does not exist', 16, 1);
        RETURN;
    END

    --3.2 Validate course has assigned instructors
    IF NOT EXISTS (SELECT 1 FROM Instructor_Course WHERE CourseID = @CourseID)
    BEGIN
        RAISERROR('No instructors are assigned to teach this course', 16, 1);
        RETURN;
    END

    --3.3 Select instructors for this course
    SELECT 
        c.CourseName,
        i.InstructorID,
        i.FirstName + ' ' + i.LastName AS InstructorName
    FROM Instructor_Course ic
    INNER JOIN Instructor i ON ic.InstructorID = i.InstructorID
    INNER JOIN Course c ON ic.CourseID = c.CourseID
    WHERE ic.CourseID = @CourseID;
END
GO

-- Example call:
-- EXEC GetInstructorsByCourseId 10;


----------------------------------------------------------- exam question 

--1. Get all Exam-Question details
CREATE PROCEDURE GetAllExamsQuestionsDetails
AS
BEGIN
    --1.1 Check if any Exam-Question records exist
    IF NOT EXISTS (SELECT 1 FROM Exam_Question)
    BEGIN
        RAISERROR('No Exam-Question records found', 16, 1);
        RETURN;
    END

    --1.2 Select all exam-question details
    SELECT 
        eq.ExamQuestionID,
        e.ExamID,
        e.ExamDate,
        q.QuestionID,
        q.QuestionText,
        eq.QuestionOrder
    FROM Exam_Question eq
    INNER JOIN Exam e ON eq.ExamID = e.ExamID
    INNER JOIN Question q ON eq.QuestionID = q.QuestionID
    ORDER BY e.ExamID, eq.QuestionOrder;
END
GO

-- Example call:
-- EXEC GetAllExamsQuestionsDetails;


--2. Get Questions by ExamID
CREATE PROCEDURE GetQuestionsByExamId
    @ExamID INT
AS
BEGIN
    --2.1 Validate exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamID = @ExamID)
    BEGIN
        RAISERROR('Exam does not exist', 16, 1);
        RETURN;
    END

    --2.2 Validate exam has assigned questions
    IF NOT EXISTS (SELECT 1 FROM Exam_Question WHERE ExamID = @ExamID)
    BEGIN
        RAISERROR('No questions assigned to this exam', 16, 1);
        RETURN;
    END

    --2.3 Select questions for this exam
    SELECT 
        q.QuestionID,
        q.QuestionText,
        q.QuestionType,
        q.QuestionMark,
        eq.QuestionOrder
    FROM Exam_Question eq
    INNER JOIN Question q ON eq.QuestionID = q.QuestionID
    WHERE eq.ExamID = @ExamID
    ORDER BY eq.QuestionOrder;
END
GO

-- Example call:
-- EXEC GetQuestionsByExamId 1;


--3. Get Exams by QuestionID
CREATE PROCEDURE GetExamsByQuestionId
    @QuestionID INT
AS
BEGIN
    --3.1 Validate question exists
    IF NOT EXISTS (SELECT 1 FROM Question WHERE QuestionID = @QuestionID)
    BEGIN
        RAISERROR('Question does not exist', 16, 1);
        RETURN;
    END

    --3.2 Validate question has been used in any exam
    IF NOT EXISTS (SELECT 1 FROM Exam_Question WHERE QuestionID = @QuestionID)
    BEGIN
        RAISERROR('This question has not been used in any exam yet', 16, 1);
        RETURN;
    END

    --3.3 Select exams containing this question
    SELECT 
        q.QuestionText,
        e.ExamID,
        e.ExamDate,
        eq.QuestionOrder
    FROM Exam_Question eq
    INNER JOIN Exam e ON eq.ExamID = e.ExamID
    INNER JOIN Question q ON eq.QuestionID = q.QuestionID
    WHERE eq.QuestionID = @QuestionID
    ORDER BY e.ExamDate DESC;
END
GO

-- Example call:
-- EXEC GetExamsByQuestionId 1;


---------------------------------------------------------------- Course Topic
-- 1. Get all Course-Topic details
CREATE PROCEDURE GetAllCoursesTopics
AS
BEGIN
    --SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Course_Topic)
        THROW 50001, 'No Course-Topic records found.', 1;

    SELECT 
        ct.CourseTopicID,
        c.CourseID,
        c.CourseName,
        t.TopicID,
        t.TopicName
    FROM Course_Topic ct
        JOIN Course c ON ct.CourseID = c.CourseID
        JOIN Topic t ON ct.TopicID = t.TopicID
    ORDER BY c.CourseName, t.TopicName;
END;
GO

-- Example:
-- EXEC GetAllCoursesTopics


-- 2. Get Courses by TopicId
CREATE PROCEDURE GetCoursesByTopicId
    @TopicId INT
AS
BEGIN
    --SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Topic WHERE TopicID = @TopicId)
        THROW 50001, 'Topic does not exist.', 1;

    IF NOT EXISTS (SELECT 1 FROM Course_Topic WHERE TopicID = @TopicId)
        THROW 50002, 'No courses assigned to this topic.', 1;

    SELECT 
        ct.CourseTopicID,
        c.CourseID,
        c.CourseName
    FROM Course_Topic ct
        JOIN Course c ON ct.CourseID = c.CourseID
    WHERE ct.TopicID = @TopicId
    ORDER BY c.CourseName;
END;
GO

-- Example:
-- EXEC GetCoursesByTopicId 3


-- 3. Get Topics by CourseId
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

-- Example:
-- EXEC GetTopicsByCourseId 4


------------------------------------------------------------- Student Exam
-- 1. Get all Student-Exam details
CREATE PROCEDURE GetAllStudentExams
AS
BEGIN
    --SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Student_Exam)
        THROW 50001, 'No Student-Exam records found.', 1;

    SELECT 
        se.StudentExamID,
        s.StudentID,
        s.FirstName + ' ' + s.LastName AS StudentName,
        e.ExamID,
        e.ExamDate,
        se.StartTime,
        se.EndTime,
        se.TotalScore,
        se.Percentage
    FROM Student_Exam se
        JOIN Student s ON se.StudentID = s.StudentID
        JOIN Exam e ON se.ExamID = e.ExamID
    ORDER BY e.ExamDate, s.LastName;
END;
GO

-- Example:
-- EXEC GetAllStudentExams


-- 2. Get Exams by StudentID
CREATE PROCEDURE GetExamsByStudentId
    @StudentId INT
AS
BEGIN
    --SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentId)
        THROW 50001, 'Student does not exist.', 1;

    IF NOT EXISTS (SELECT 1 FROM Student_Exam WHERE StudentID = @StudentId)
        THROW 50002, 'This student has not taken any exams yet.', 1;

    SELECT 
        se.StudentExamID,
        e.ExamID,
        e.ExamDate,
        se.StartTime,
        se.EndTime,
        se.TotalScore,
        se.Percentage
    FROM Student_Exam se
        JOIN Exam e ON se.ExamID = e.ExamID
    WHERE se.StudentID = @StudentId
    ORDER BY e.ExamDate DESC;
END;
GO

-- Example:
-- EXEC GetExamsByStudentId 1


-- 3. Get Students by ExamID
CREATE PROCEDURE GetStudentsByExamId
    @ExamId INT
AS
BEGIN
    --SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamID = @ExamId)
        THROW 50001, 'Exam does not exist.', 1;

    IF NOT EXISTS (SELECT 1 FROM Student_Exam WHERE ExamID = @ExamId)
        THROW 50002, 'No students have taken this exam yet.', 1;

    SELECT 
        se.StudentExamID,
        s.StudentID,
        s.FirstName + ' ' + s.LastName AS StudentName,
        se.StartTime,
        se.EndTime,
        se.TotalScore,
        se.Percentage
    FROM Student_Exam se
        JOIN Student s ON se.StudentID = s.StudentID
    WHERE se.ExamID = @ExamId
    ORDER BY s.LastName;
END;
GO

-- Example:
-- EXEC GetStudentsByExamId 1


------------------------------------------------- Student Answer
-- 1. Get all Student-Answer details
CREATE PROCEDURE GetAllStudentAnswers
AS
BEGIN
    --SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Student_Answer)
        THROW 50001, 'No Student-Answer records found.', 1;

    SELECT 
        sa.StudentAnswerID,
        s.StudentID,
        s.FirstName + ' ' + s.LastName AS StudentName,
        e.ExamID,
        q.QuestionID,
        q.QuestionText,
        ch.ChoiceID,
        ch.ChoiceLabel,
        ch.ChoiceText,
        sa.IsCorrect,
        sa.Mark
    FROM Student_Answer sa
        JOIN Student_Exam se ON sa.StudentExamID = se.StudentExamID
        JOIN Student s ON se.StudentID = s.StudentID
        JOIN Exam e ON se.ExamID = e.ExamID
        JOIN Question q ON sa.QuestionID = q.QuestionID
        LEFT JOIN Choice ch ON sa.AnswerID = ch.ChoiceID
    ORDER BY e.ExamID, s.LastName, q.QuestionID;
END;
GO

-- Example:
-- EXEC GetAllStudentAnswers


-- 2. Get Questions & Answers of a student's exam by StudentID & ExamID
CREATE PROCEDURE GetAnswersByStudentIDAndExamID
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    --SET NOCOUNT ON;

    DECLARE @StudentExamID INT;

    --1. Validate FK existence

    -- Check Student exists
    IF NOT EXISTS (
        SELECT 1
        FROM Student
        WHERE StudentID = @StudentID
    )
        THROW 50001, 'Student does not exist.', 1;

    -- Check Exam exists
    IF NOT EXISTS (
        SELECT 1
        FROM Exam
        WHERE ExamID = @ExamID
    )
        THROW 50002, 'Exam does not exist.', 1;

    --2. Get StudentExamID

    SELECT @StudentExamID = StudentExamID
    FROM Student_Exam
    WHERE StudentID = @StudentID
      AND ExamID = @ExamID;

    IF @StudentExamID IS NULL
        THROW 50003, 'Student is not registered for this exam.', 1;

    --3. Check answers exist

    IF NOT EXISTS (
        SELECT 1
        FROM Student_Answer
        WHERE StudentExamID = @StudentExamID
    )
        THROW 50004, 'No answers recorded for this exam.', 1;

    --4. Return answers

    SELECT 
        sa.StudentAnswerID,
        q.QuestionID,
        q.QuestionText,
        ch.ChoiceID,
        ch.ChoiceLabel,
        ch.ChoiceText,
        sa.IsCorrect,
        sa.Mark
    FROM Student_Answer sa
        JOIN Question q ON sa.QuestionID = q.QuestionID
        LEFT JOIN Choice ch ON sa.AnswerID = ch.ChoiceID
    WHERE sa.StudentExamID = @StudentExamID
    ORDER BY q.QuestionID;
END;
GO

-- Example:
-- EXEC GetAnswersByStudentIDAndExamID 2,6


-- 3. Get Student Answers by QuestionID  -------- doesn't have a meaning , same for Get Student Answers by AnswerID
CREATE PROCEDURE GetStudentAnswersByQuestionId
    @QuestionID INT
AS
BEGIN
    --SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Question WHERE QuestionID = @QuestionID)
        THROW 50001, 'Question does not exist.', 1;

    IF NOT EXISTS (SELECT 1 FROM Student_Answer WHERE QuestionID = @QuestionID)
        THROW 50002, 'No student has answered this question yet.', 1;

    SELECT 
        sa.StudentAnswerID,
        s.StudentID,
        s.FirstName + ' ' + s.LastName AS StudentName,
        se.ExamID,
        sa.AnswerID,
        ch.ChoiceLabel,
        ch.ChoiceText,
        sa.IsCorrect,
        sa.Mark
    FROM Student_Answer sa
        JOIN Student_Exam se ON sa.StudentExamID = se.StudentExamID
        JOIN Student s ON se.StudentID = s.StudentID
        LEFT JOIN Choice ch ON sa.AnswerID = ch.ChoiceID
    WHERE sa.QuestionID = @QuestionID
    ORDER BY se.ExamID, s.LastName;
END;
GO

-- Example:
-- EXEC GetStudentAnswersByQuestionId 1



-- /////////////////////////////////////////////////////// INSERT


----------------------------------------------------------- Branch_Track
CREATE PROCEDURE AddBranchTrack
    @BranchID INT,
    @TrackID INT
AS
BEGIN
    --SET NOCOUNT ON;

    BEGIN TRY
        --1.1 Validate Branch exists
        IF NOT EXISTS (SELECT 1 FROM Branch WHERE BranchID = @BranchID)
            THROW 50001, 'BranchID does not exist', 1;

        --1.2 Validate Track exists
        IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackID = @TrackID)
            THROW 50002, 'TrackID does not exist', 1;

        --1.3 Check if this Branch-Track relation already exists
        IF EXISTS (
            SELECT 1
            FROM Branch_Track
            WHERE BranchID = @BranchID
              AND TrackID = @TrackID
        )
            THROW 50003, 'Branch-Track relation already exists', 1;

        --1.4 Insert Branch-Track relation
        INSERT INTO Branch_Track (BranchID, TrackID)
        VALUES (@BranchID, @TrackID);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Example call:
-- EXEC AddBranchTrack 1, 2;


---------------------------------------------------------- Track-Instructor
CREATE PROCEDURE AddTrackInstructor
    @TrackId INT,
    @InstructorId INT
AS
BEGIN
    --SET NOCOUNT ON;

    BEGIN TRY
        --1. Validate Track exists
        IF NOT EXISTS (
            SELECT 1
            FROM Track
            WHERE TrackID = @TrackId
        )
            THROW 50001, 'Track does not exist.', 1;

        --2. Validate Instructor exists
        IF NOT EXISTS (
            SELECT 1
            FROM Instructor
            WHERE InstructorID = @InstructorId
        )
            THROW 50002, 'Instructor does not exist.', 1;

        --3. Check if this Track-Instructor assignment already exists
        IF EXISTS (
            SELECT 1
            FROM Track_Instructor
            WHERE TrackID = @TrackId
              AND InstructorID = @InstructorId
        )
            THROW 50003, 'Instructor already assigned to this Track.', 1;

        --4. Insert Track-Instructor record
        INSERT INTO Track_Instructor (TrackID, InstructorID)
        VALUES (@TrackId, @InstructorId);

    END TRY
    BEGIN CATCH
        THROW; -- Propagate any error
    END CATCH
END;
GO

-- Example usage:
-- EXEC AddTrackInstructor 3, 9



---------------------------------------------------------------- Add Track-Course
CREATE PROCEDURE AddTrackCourse
    @TrackId INT,
    @CourseId INT
AS
BEGIN
    --SET NOCOUNT ON;

    BEGIN TRY
        --1. Validate Track exists
        IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackID = @TrackId)

            THROW 50001, 'TrackID does not exist.', 1;


        --2. Validate Course exists
        IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseId)

            THROW 50002, 'CourseID does not exist.', 1;


        --3. Check if Track-Course relationship already exists
        IF EXISTS (
            SELECT 1 
            FROM Track_Course
            WHERE TrackID = @TrackId
              AND CourseID = @CourseId
        )

            THROW 50003, 'Track-Course relationship already exists.', 1;


        --4. Insert Track-Course
        INSERT INTO Track_Course (TrackID, CourseID)
        VALUES (@TrackId, @CourseId);

    END TRY
    BEGIN CATCH
        THROW; -- Propagate any error to the caller
    END CATCH
END;
GO

-- Example usage:
-- EXEC AddTrackCourse 99, 99


------------------------------------------------- Add Instructor-Course
CREATE PROCEDURE AddInstructorCourse
    @InstructorId INT,
    @CourseId INT
AS
BEGIN
    --SET NOCOUNT ON;

    BEGIN TRY
        --1. Validate Instructor exists
        IF NOT EXISTS (
            SELECT 1
            FROM Instructor
            WHERE InstructorID = @InstructorId
        )
            THROW 50001, 'Instructor does not exist.', 1;

        --2. Validate Course exists
        IF NOT EXISTS (
            SELECT 1
            FROM Course
            WHERE CourseID = @CourseId
        )
            THROW 50002, 'Course does not exist.', 1;

        --3. Check if Instructor is already assigned to this Course
        IF EXISTS (
            SELECT 1
            FROM Instructor_Course
            WHERE InstructorID = @InstructorId
              AND CourseID = @CourseId
        )
            THROW 50003, 'Instructor already assigned to this Course.', 1;

        --4. Insert Instructor-Course record
        INSERT INTO Instructor_Course (InstructorID, CourseID)
        VALUES (@InstructorId, @CourseId);

    END TRY
    BEGIN CATCH
        THROW; -- Propagate any error
    END CATCH
END;
GO

-- Example usage:
-- EXEC AddInstructorCourse 1, 99


-------------------------------------------------- Insert Exam-Question
CREATE PROCEDURE AddExamQuestion
    @ExamId INT,
    @QuestionId INT,
    @QuestionOrder INT
AS
BEGIN
    --SET NOCOUNT ON;

    BEGIN TRY
        --1. Validate Exam exists
        IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamID = @ExamId)
            THROW 50001, 'ExamID does not exist.', 1;

        --2. Validate Question exists
        IF NOT EXISTS (SELECT 1 FROM Question WHERE QuestionID = @QuestionId)
            THROW 50002, 'QuestionID does not exist.', 1;

        --3. Check if Question is already assigned to this Exam
        IF EXISTS (
            SELECT 1 
            FROM Exam_Question
            WHERE ExamID = @ExamId
              AND QuestionID = @QuestionId
        )
            THROW 50003, 'Question already assigned to this Exam.', 1;

        --4. Insert Exam-Question record
        INSERT INTO Exam_Question (ExamID, QuestionID, QuestionOrder)
        VALUES (@ExamId, @QuestionId, @QuestionOrder);

    END TRY
    BEGIN CATCH
        THROW; -- Propagate any error
    END CATCH
END;
GO

-- Example usage:
-- EXEC AddExamQuestion 99, 99, 1


------------------------------------------------- Add Course-Topic
CREATE PROCEDURE AddCourseTopic
    @CourseId INT,
    @TopicId INT
AS
BEGIN
    --SET NOCOUNT ON;

    BEGIN TRY
        --1. Validate Course exists
        IF NOT EXISTS (
            SELECT 1
            FROM Course
            WHERE CourseID = @CourseId
        )
            THROW 50001, 'Course does not exist.', 1;

        --2. Validate Topic exists
        IF NOT EXISTS (
            SELECT 1
            FROM Topic
            WHERE TopicID = @TopicId
        )
            THROW 50002, 'Topic does not exist.', 1;

        --3. Check if this Course-Topic assignment already exists
        IF EXISTS (
            SELECT 1
            FROM Course_Topic
            WHERE CourseID = @CourseId
              AND TopicID = @TopicId
        )
            THROW 50003, 'Topic already assigned to this Course.', 1;

        --4. Insert Course-Topic record
        INSERT INTO Course_Topic (CourseID, TopicID)
        VALUES (@CourseId, @TopicId);

    END TRY
    BEGIN CATCH
        THROW; -- Propagate any error
    END CATCH
END;
GO

-- Example usage:
-- EXEC AddCourseTopic 4, 2


-- ////////////////////////////////////////////////////////////////////////////////////////// empty answers for student

-- this will be used for bulk insertion 

CREATE PROCEDURE AddStudentExamQuestions
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    --SET NOCOUNT ON;

    DECLARE @StudentExamID INT;
    DECLARE @QuestionID INT;


    --1. Validate Student

    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
        THROW 71001, 'Student does not exist.', 1;


    --2. Validate Exam

    IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamID = @ExamID)
        THROW 71002, 'Exam does not exist.', 1;


    --3. Get StudentExamID

    SELECT @StudentExamID = StudentExamID
    FROM Student_Exam
    WHERE StudentID = @StudentID
      AND ExamID = @ExamID;

    IF @StudentExamID IS NULL
        THROW 71003, 'StudentExam record does not exist.', 1;


    --4. Declare table variable to hold 10 questions

    DECLARE @ExamQuestions TABLE
    (
        QuestionID INT NOT NULL,
        QuestionOrder INT NOT NULL
    );


    --5. Get 10 questions of exam ordered by Exam_Question

    INSERT INTO @ExamQuestions (QuestionID, QuestionOrder)
    SELECT TOP (10)
        eq.QuestionID,
        eq.QuestionOrder
    FROM Exam_Question eq
    WHERE eq.ExamID = @ExamID
    ORDER BY eq.QuestionOrder;

    IF (SELECT COUNT(*) FROM @ExamQuestions) < 10
        THROW 71004, 'Exam does not contain 10 questions.', 1;


    --6. Cursor to insert Student_Answer rows

    DECLARE QuestionCursor CURSOR FOR
        SELECT QuestionID
        FROM @ExamQuestions
        ORDER BY QuestionOrder;

    OPEN QuestionCursor;

    FETCH NEXT FROM QuestionCursor INTO @QuestionID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO Student_Answer
        (
            StudentExamID,
            QuestionID,
            AnswerID,
            IsCorrect,
            Mark
        )
        VALUES
        (
            @StudentExamID,
            @QuestionID,
            NULL,
            NULL,
            NULL
        );

        FETCH NEXT FROM QuestionCursor INTO @QuestionID;
    END;

    CLOSE QuestionCursor;
    DEALLOCATE QuestionCursor;

END;
GO



--------------------------------------------------------------------- Insert Student_Exam
CREATE PROCEDURE AddStudentExam
    @StudentID INT,
    @ExamID INT,
    @StudentStartTime DATETIME,
    @StudentEndTime DATETIME
AS
BEGIN
    --SET NOCOUNT ON;

    DECLARE @ExamStart DATETIME;
    DECLARE @ExamEnd DATETIME;
    DECLARE @Now DATETIME = GETDATE();


    --1. Validate exam exists
    IF NOT EXISTS (
        SELECT 1
        FROM Exam
        WHERE ExamID = @ExamID
    )
        THROW 61003, 'Exam does not exist', 1;

    --2. Validate exam has questions
    IF NOT EXISTS (
        SELECT 1
        FROM Exam_Question
        WHERE ExamID = @ExamID
    )
        THROW 61003, 'This Exam does not have questions yet', 1;


    --3. Validate current time is within exam window
    SELECT
        @ExamStart = CAST(ExamDate AS DATETIME) + CAST(StartTime AS DATETIME),
        @ExamEnd   = CAST(ExamDate AS DATETIME) + CAST(EndTime AS DATETIME)
    FROM Exam
    WHERE ExamID = @ExamID;

    IF @ExamStart IS NULL
        THROW 61000, 'Exam does not exist', 1;

    IF @Now < @ExamStart
        THROW 61001, 'Exam has not started yet', 1;

    IF @Now > @ExamEnd
        THROW 61002, 'Exam time is over', 1;

    --4. Validate student exists
    IF NOT EXISTS (
        SELECT 1
        FROM Student
        WHERE StudentID = @StudentID
    )
        THROW 61003, 'Student does not exist', 1;

    --5. Prevent duplicate Student-Exam
    IF EXISTS (
        SELECT 1
        FROM Student_Exam
        WHERE StudentID = @StudentID
          AND ExamID = @ExamID
    )
        THROW 61004, 'Student already registered for this exam', 1;

    --6. Validate student start < student end
    IF @StudentStartTime >= @StudentEndTime
        THROW 61005, 'Student start time must be before end time', 1;

    --7. Validate student start is within exam time
    IF @StudentStartTime < @ExamStart OR @StudentStartTime > @ExamEnd
        THROW 61006, 'Student start time must be within exam time', 1;

    --8. Validate student end is within exam time
    IF @StudentEndTime < @ExamStart OR @StudentEndTime > @ExamEnd
        THROW 61007, 'Student end time must be within exam time', 1;

    --9. Insert Student_Exam
    INSERT INTO Student_Exam (
        StudentID,
        ExamID,
        StartTime,
        EndTime
    )
    VALUES (
        @StudentID,
        @ExamID,
        @StudentStartTime,
        @StudentEndTime
    );

    EXEC AddStudentExamQuestions @StudentID, @ExamID

END;
GO


---------------------------------------------------------------- Insert Student_Answer
CREATE PROCEDURE AddStudentAnswer
    @StudentID INT,
    @ExamID INT,
    @QuestionID INT,
    @AnswerID INT
AS
BEGIN
    --SET NOCOUNT ON;

    DECLARE @IsCorrect BIT;
    DECLARE @QuestionMark DECIMAL(5,2);
    DECLARE @Now DATETIME = GETDATE();
    DECLARE @ExamStart DATETIME;
    DECLARE @ExamEnd DATETIME;
    DECLARE @StudentExamID INT;

    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
        THROW 70603, 'Student does not exist', 1;

    IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamID = @ExamID)
        THROW 70602, 'Exam does not exist', 1;

    -- get StudentExamID
    SELECT @StudentExamID = StudentExamID
    FROM Student_Exam
    WHERE StudentID = @StudentID
      AND ExamID = @ExamID;

    IF @StudentExamID IS NULL
        THROW 70700, 'StudentExam does not exist', 1;

    --1. Validate exam time window (BEFORE any other validation)
    SELECT 
        @ExamStart = CAST(e.ExamDate AS DATETIME) + CAST(e.StartTime AS DATETIME),
        @ExamEnd   = CAST(e.ExamDate AS DATETIME) + CAST(e.EndTime AS DATETIME)
    FROM Student_Exam se
    JOIN Exam e ON se.ExamID = e.ExamID
    WHERE se.StudentExamID = @StudentExamID;

    IF @Now < @ExamStart
        THROW 60010, 'Exam has not started yet', 1;

    IF @Now > @ExamEnd
        THROW 60011, 'Exam time is over', 1;

    --2. Validate Question exists
    IF NOT EXISTS (
        SELECT 1
        FROM Question
        WHERE QuestionID = @QuestionID
    )
        THROW 60002, 'Question does not exist', 1;

    --3. Validate Answer exists
    IF NOT EXISTS (
        SELECT 1
        FROM Choice
        WHERE ChoiceID = @AnswerID
    )
        THROW 60003, 'Answer does not exist', 1;

    --4. Validate Question belongs to the Exam
    IF NOT EXISTS (
        SELECT 1
        FROM Exam_Question eq
        JOIN Student_Exam se ON se.ExamID = eq.ExamID
        WHERE se.StudentExamID = @StudentExamID
          AND eq.QuestionID = @QuestionID
    )
        THROW 60004, 'Question does not belong to this student exam', 1;

    --5. Validate Answer belongs to the Question
    IF NOT EXISTS (
        SELECT 1
        FROM Choice
        WHERE ChoiceID = @AnswerID
          AND QuestionID = @QuestionID
    )
        THROW 60005, 'Answer does not belong to this question', 1;

    --6. Prevent duplicate student answer
    /*IF EXISTS (
        SELECT 1
        FROM Student_Answer
        WHERE StudentExamID = @StudentExamID
          AND QuestionID = @QuestionID
    )
        THROW 60006, 'answer already submitted for this question.', 1;*/

    --7. Determine correctness
    SELECT 
        @IsCorrect = CASE 
                        WHEN IsCorrectChoice = 1 THEN 1 
                        ELSE 0 
                     END
    FROM Choice
    WHERE ChoiceID = @AnswerID;

    --8. Get question mark
    SELECT 
         
        @QuestionMark = CASE 
                            WHEN @IsCorrect = 1 THEN QuestionMark
                            ELSE 0
                        END
    FROM Question
    WHERE QuestionID = @QuestionID;


    --9. Update student answer
    UPDATE Student_Answer
    SET
        AnswerID = @AnswerID,
        IsCorrect = @IsCorrect,
        Mark = @QuestionMark
    WHERE
        StudentExamID = @StudentExamID
        AND QuestionID = @QuestionID;

END;
GO

-- ///////////////////////////////////////////////////////////////////////////// DELETE

------------------------------------------------------------------------------- Branch-Track

--1. Delete one Branch-Track
CREATE PROC DeleteBranchTrack
    @BranchID INT,
    @TrackID INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Branch_Track
        WHERE BranchID = @BranchID AND TrackID = @TrackID
    )
        THROW 70001, 'Branch-Track record not found', 1;

    DELETE FROM Branch_Track
    WHERE BranchID = @BranchID AND TrackID = @TrackID;
END;
GO

--2. Delete tracks by BranchID
CREATE PROC DeleteTracksByBranchID
    @BranchID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Branch WHERE BranchID = @BranchID)
        THROW 70002, 'Branch does not exist', 1;

    DELETE FROM Branch_Track
    WHERE BranchID = @BranchID;
END;
GO

--3. Delete branches by TrackID
CREATE PROC DeleteBranchesByTrackID
    @TrackID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackID = @TrackID)
        THROW 70003, 'Track does not exist', 1;

    DELETE FROM Branch_Track
    WHERE TrackID = @TrackID;
END;
GO

------------------------------------------------------------------------------- Track-Instructor

--1. Delete one Track-Instructor
CREATE PROC DeleteTrackInstructor
    @TrackID INT,
    @InstructorID INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Track_Instructor
        WHERE TrackID = @TrackID AND InstructorID = @InstructorID
    )
        THROW 70101, 'Track-Instructor record not found', 1;

    DELETE FROM Track_Instructor
    WHERE TrackID = @TrackID AND InstructorID = @InstructorID;
END;
GO

--2. Delete instructors by TrackID
CREATE PROC DeleteInstructorsByTrackID
    @TrackID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackID = @TrackID)
        THROW 70102, 'Track does not exist', 1;

    DELETE FROM Track_Instructor
    WHERE TrackID = @TrackID;
END;
GO

--3. Delete tracks by InstructorID
CREATE PROC DeleteTracksByInstructorID
    @InstructorID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = @InstructorID)
        THROW 70103, 'Instructor does not exist', 1;

    DELETE FROM Track_Instructor
    WHERE InstructorID = @InstructorID;
END;
GO

------------------------------------------------------------------------------- Track-Course

--1. Delete one Track-Course
CREATE PROC DeleteTrackCourse
    @TrackID INT,
    @CourseID INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Track_Course
        WHERE TrackID = @TrackID AND CourseID = @CourseID
    )
        THROW 70201, 'Track-Course record not found', 1;

    DELETE FROM Track_Course
    WHERE TrackID = @TrackID AND CourseID = @CourseID;
END;
GO

--2. Delete courses by TrackID
CREATE PROC DeleteCoursesByTrackID
    @TrackID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackID = @TrackID)
        THROW 70202, 'Track does not exist', 1;

    DELETE FROM Track_Course
    WHERE TrackID = @TrackID;
END;
GO

--3. Delete tracks by CourseID
CREATE PROC DeleteTracksByCourseID
    @CourseID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseID)
        THROW 70203, 'Course does not exist', 1;

    DELETE FROM Track_Course
    WHERE CourseID = @CourseID;
END;
GO

------------------------------------------------------------------------------- Instructor-Course

--1. Delete one Instructor-Course
CREATE PROC DeleteInstructorCourse
    @InstructorID INT,
    @CourseID INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Instructor_Course
        WHERE InstructorID = @InstructorID AND CourseID = @CourseID
    )
        THROW 70301, 'Instructor-Course record not found', 1;

    DELETE FROM Instructor_Course
    WHERE InstructorID = @InstructorID AND CourseID = @CourseID;
END;
GO

--2. Delete courses by InstructorID
CREATE PROC DeleteCoursesByInstructorID
    @InstructorID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = @InstructorID)
        THROW 70302, 'Instructor does not exist', 1;

    DELETE FROM Instructor_Course
    WHERE InstructorID = @InstructorID;
END;
GO

--3. Delete instructors by CourseID
CREATE PROC DeleteInstructorsByCourseID
    @CourseID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseID)
        THROW 70303, 'Course does not exist', 1;

    DELETE FROM Instructor_Course
    WHERE CourseID = @CourseID;
END;
GO


------------------------------------------------------------------------------- Course-Topic

--1. Delete one Course-Topic
CREATE PROC DeleteCourseTopic
    @CourseID INT,
    @TopicID INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Course_Topic
        WHERE CourseID = @CourseID AND TopicID = @TopicID
    )
        THROW 70401, 'Course-Topic record not found', 1;

    DELETE FROM Course_Topic
    WHERE CourseID = @CourseID AND TopicID = @TopicID;
END;
GO

--2. Delete topics by CourseID
CREATE PROC DeleteTopicsByCourseID
    @CourseID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseID)
        THROW 70402, 'Course does not exist', 1;

    DELETE FROM Course_Topic
    WHERE CourseID = @CourseID;
END;
GO

--3. Delete courses by TopicID
CREATE PROC DeleteCoursesByTopicID
    @TopicID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Topic WHERE TopicID = @TopicID)
        THROW 70403, 'Topic does not exist', 1;

    DELETE FROM Course_Topic
    WHERE TopicID = @TopicID;
END;
GO

------------------------------------------------------------------------------- Exam-Question

--1. Delete one Exam-Question
CREATE PROC DeleteExamQuestion
    @ExamID INT,
    @QuestionID INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Exam_Question
        WHERE ExamID = @ExamID AND QuestionID = @QuestionID
    )
        THROW 70501, 'Exam-Question record not found', 1;

    DELETE FROM Exam_Question
    WHERE ExamID = @ExamID AND QuestionID = @QuestionID;
END;
GO

--2. Delete questions by ExamID
CREATE PROC DeleteQuestionsByExamID
    @ExamID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamID = @ExamID)
        THROW 70502, 'Exam does not exist', 1;

    DELETE FROM Exam_Question
    WHERE ExamID = @ExamID;
END;
GO

--3. Delete exams by QuestionID
CREATE PROC DeleteExamsByQuestionID
    @QuestionID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Question WHERE QuestionID = @QuestionID)
        THROW 70503, 'Question does not exist', 1;

    DELETE FROM Exam_Question
    WHERE QuestionID = @QuestionID;
END;
GO

------------------------------------------------------------------------------- Student-Exam

--1. Delete one Student-Exam
CREATE PROC DeleteStudentExam
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Student_Exam
        WHERE StudentID = @StudentID AND ExamID = @ExamID
    )
        THROW 70601, 'Student-Exam record not found', 1;

    DELETE FROM Student_Exam
    WHERE StudentID = @StudentID AND ExamID = @ExamID;
END;
GO

--2. Delete students by ExamID
CREATE PROC DeleteStudentsByExamID
    @ExamID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamID = @ExamID)
        THROW 70602, 'Exam does not exist', 1;

    DELETE FROM Student_Exam
    WHERE ExamID = @ExamID;
END;
GO

--3. Delete exams by StudentID
CREATE PROC DeleteExamsByStudentID
    @StudentID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
        THROW 70603, 'Student does not exist', 1;

    DELETE FROM Student_Exam
    WHERE StudentID = @StudentID;
END;
GO

------------------------------------------------------------------------------- Student-Answer

--1. Delete one Student-Answer
CREATE PROC DeleteStudentAnswer
    @StudentID INT,
    @ExamID INT,
    @QuestionID INT,
    @AnswerID INT
AS
BEGIN
    DECLARE @StudentExamID INT;

    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
        THROW 70603, 'Student does not exist', 1;

    IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamID = @ExamID)
        THROW 70602, 'Exam does not exist', 1;

    -- get StudentExamID
    SELECT @StudentExamID = StudentExamID
    FROM Student_Exam
    WHERE StudentID = @StudentID
      AND ExamID = @ExamID;

    IF @StudentExamID IS NULL
        THROW 70700, 'StudentExam does not exist', 1;

    DELETE FROM Student_Answer
    WHERE StudentExamID = @StudentExamID
      AND QuestionID = @QuestionID
      AND AnswerID = @AnswerID;
END;
GO

--2. Delete answers by StudentExamID
CREATE PROC DeleteAnswersByStudentExamID
    @StudentID INT,
    @ExamID INT
AS
BEGIN

    DECLARE @StudentExamID INT;

    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
        THROW 70603, 'Student does not exist', 1;

    IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamID = @ExamID)
        THROW 70602, 'Exam does not exist', 1;

    -- get StudentExamID
    SELECT @StudentExamID = StudentExamID
    FROM Student_Exam
    WHERE StudentID = @StudentID
      AND ExamID = @ExamID;

    IF @StudentExamID IS NULL
        THROW 70700, 'StudentExam does not exist', 1;


    DELETE FROM Student_Answer
    WHERE StudentExamID = @StudentExamID;
END;
GO

--///////////////////////////////////////////////////////////////////////// UPDATE

------------------Update
---- instructor course 

create procedure UpdateInstructorCourse
    @InstructorID int,
    @OldCourseID int,
    @NewCourseID int
as
begin
    --set nocount on;

    if not exists (
        select 1
        from Instructor
        where InstructorID = @InstructorID
    )
        throw 50001, 'instructor does not exist', 1;

    if not exists (
        select 1
        from Course
        where CourseID = @OldCourseID
    )
        throw 50002, 'old course does not exist', 1;

    if not exists (
        select 1
        from Course
        where CourseID = @NewCourseID
    )
        throw 50003, 'new course does not exist', 1;

    if not exists (
        select 1
        from Instructor_Course
        where InstructorID = @InstructorID
          and CourseID = @OldCourseID
    )
        throw 50004, 'instructor is not assigned to the old course', 1;

    if exists (
        select 1
        from Instructor_Course
        where InstructorID = @InstructorID
          and CourseID = @NewCourseID
    )
        throw 50005, 'instructor already assigned to the new course', 1;

    update Instructor_Course
    set CourseID = @NewCourseID
    where InstructorID = @InstructorID
      and CourseID = @OldCourseID;

select 'instructor course updated successfully' as message;
end;

go
-- UpdateInstructorCourse 1,1,1







-- trackCourse 

create procedure UpdateTrackCourse
    @trackid int,
    @oldcourseid int,
    @newcourseid int
as
begin
    --set nocount on;

    if not exists (select 1 from track where trackid = @trackid)
        throw 51001, 'track does not exist', 1;

    if not exists (select 1 from course where courseid = @oldcourseid)
        throw 51002, 'old course does not exist', 1;

    if not exists (select 1 from course where courseid = @newcourseid)
        throw 51003, 'new course does not exist', 1;

    if not exists (
        select 1 from track_course
        where trackid = @trackid and courseid = @oldcourseid
    )
        throw 51004, 'track is not assigned to the old course', 1;

    if exists (
        select 1 from track_course
        where trackid = @trackid and courseid = @newcourseid
    )
        throw 51005, 'track already assigned to the new course', 1;

    update track_course
    set courseid = @newcourseid
    where trackid = @trackid and courseid = @oldcourseid;

    select 'track course updated successfully' as message;
end;

go
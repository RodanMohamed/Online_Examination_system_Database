--A) Insert Stored Procedures

--1. Insert into Bracnch
CREATE PROCEDURE AddBranch
    @BranchName VARCHAR(100),
    @BranchLocation VARCHAR(200)
AS
BEGIN
    --SET NOCOUNT ON;

    -- 1. Check that BranchName contains only letters and spaces
    IF @BranchName LIKE '%[0-9]%'
    BEGIN
        RAISERROR('Branch name can not contain numbers.', 16, 1);
        RETURN;
    END;

    -- 2. Check for duplicate branch name
    IF EXISTS (
        SELECT 1
        FROM Branch
        WHERE BranchName = @BranchName
    )
    BEGIN
        RAISERROR('Branch name already exists.', 16, 1);
        RETURN;
    END;

    -- 3. Insert branch
    INSERT INTO Branch (BranchName, BranchLocation)
    VALUES (@BranchName, @BranchLocation);
END;
GO



--2. Insert into Track
CREATE PROCEDURE AddTrack
    @TrackName VARCHAR(100),
    @TrackSupervisor INT
AS
BEGIN
    --SET NOCOUNT ON;

    -- 1. Validate TrackName contains only letters and spaces
    IF @TrackName LIKE '%[0-9]%'
    BEGIN
        RAISERROR('Track name can not contain numbers.', 16, 1);
        RETURN;
    END;

    -- 2. Check for duplicate TrackName
    IF EXISTS (
        SELECT 1
        FROM Track
        WHERE TrackName = @TrackName
    )
    BEGIN
        RAISERROR('Track name already exists.', 16, 1);
        RETURN;
    END;

    -- 3. Check that TrackSupervisor exists
    IF NOT EXISTS (
        SELECT 1
        FROM Instructor
        WHERE InstructorID = @TrackSupervisor
    )
    BEGIN
        RAISERROR('Instructor does not exist.',16,1);
        RETURN;
    END;

    -- 4. Insert Track
    INSERT INTO Track (TrackName, TrackSupervisor)
    VALUES (@TrackName, @TrackSupervisor);
END;
GO



--3. Insert into Instructor 
CREATE PROCEDURE AddInstructor
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @Phone VARCHAR(20)
AS
BEGIN
    --SET NOCOUNT ON;

    -- 1. Validate first and last names (letters + special chars, no numbers)
    IF @FirstName LIKE '%[0-9]%' OR @LastName LIKE '%[0-9]%'
    BEGIN
        RAISERROR('First and Last names cannot contain numbers.', 16, 1);
        RETURN;
    END;

    -- 2. Validate email format (basic)
    IF @Email NOT LIKE '%_@__%.__%'
    BEGIN
        RAISERROR('Invalid email format.', 16, 1);
        RETURN;
    END;

    -- 3. Validate email uniqueness
    IF EXISTS (
        SELECT 1
        FROM Instructor
        WHERE Email = @Email
    )
    BEGIN
        RAISERROR('Email already exists.', 16, 1);
        RETURN;
    END;

    -- 4. Validate phone format 
    IF @Phone LIKE '%[^0-9+]%' OR LEN(@Phone) < 10 OR LEN(@Phone) > 15
    BEGIN
        RAISERROR('Phone number must contain only digits (optionally +) and be 10-15 characters long.', 16, 1);
        RETURN;
    END;

    -- 5. Insert instructor
    INSERT INTO Instructor (FirstName, LastName, Email, Phone)
    VALUES (@FirstName, @LastName, @Email, @Phone);
END;
GO




--4.Insert into Student 
CREATE PROCEDURE AddStudent
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @Phone VARCHAR(20),
    @DateOfBirth DATE,
    @TrackID INT
AS
BEGIN
    --SET NOCOUNT ON;

    -- 1. Validate first and last names (letters + special chars, no numbers)
    IF @FirstName LIKE '%[0-9]%' OR @LastName LIKE '%[0-9]%'
    BEGIN
        RAISERROR('First and Last names cannot contain numbers.', 16, 1);
        RETURN;
    END;

    -- 2. Check that Track exists
    IF NOT EXISTS (
        SELECT 1 FROM Track
        WHERE TrackID = @TrackID
    )
    BEGIN
        RAISERROR('Track does not exist.', 16, 1);
        RETURN;
    END;

    -- 3. Validate age between 18 and 45
    DECLARE @Age INT;
    SET @Age = DATEDIFF(YEAR, @DateOfBirth, GETDATE())
               - CASE 
                   WHEN MONTH(@DateOfBirth) > MONTH(GETDATE())
                     OR (MONTH(@DateOfBirth) = MONTH(GETDATE()) AND DAY(@DateOfBirth) > DAY(GETDATE()))
                   THEN 1 ELSE 0 END;

    IF @Age < 18 OR @Age > 45
    BEGIN
        RAISERROR('Student age must be between 18 and 45.', 16, 1);
        RETURN;
    END;

    -- 4. Validate email format (basic)
    IF @Email NOT LIKE '%_@__%.__%'
    BEGIN
        RAISERROR('Invalid email format.', 16, 1);
        RETURN;
    END;

    -- 5. Validate email uniqueness
    IF EXISTS (
        SELECT 1
        FROM Student
        WHERE Email = @Email
    )
    BEGIN
        RAISERROR('Email already exists.', 16, 1);
        RETURN;
    END;

    -- 6. Validate phone format (digits only, optional +, length 10-15)
    IF @Phone LIKE '%[^0-9+]%' OR LEN(@Phone) < 10 OR LEN(@Phone) > 15
    BEGIN
        RAISERROR('Phone number must contain only digits (optionally +) and be 10-15 characters long.', 16, 1);
        RETURN;
    END;

    -- 7. Insert student
    INSERT INTO Student (FirstName, LastName, Email, Phone, DateOfBirth, TrackID)
    VALUES (@FirstName, @LastName, @Email, @Phone, @DateOfBirth, @TrackID);
END;
GO




--5.Insert into Course 
CREATE PROCEDURE AddCourse
    @CourseName VARCHAR(50),
    @MinPassDegree DECIMAL(5,2)
AS
BEGIN
    --SET NOCOUNT ON;

    -- 1. Check for numbers in CourseName
    IF @CourseName LIKE '%[0-9]%'
    BEGIN
        RAISERROR('Course name cannot contain numbers.', 16, 1);
        RETURN;
    END;

    -- 2. Check for duplicate course name
    IF EXISTS (
        SELECT 1
        FROM Course
        WHERE CourseName = @CourseName
    )
    BEGIN
        RAISERROR('Course name already exists.', 16, 1);
        RETURN;
    END;

    -- 3. Validate MinPassDegree between 0 and 100
    IF @MinPassDegree < 0 OR @MinPassDegree > 100
    BEGIN
        RAISERROR('MinPassDegree must be between 0 and 100.', 16, 1);
        RETURN;
    END;

    -- 4. Insert course
    INSERT INTO Course (CourseName, MinPassDegree)
    VALUES (@CourseName, @MinPassDegree);
END;
GO


CREATE PROCEDURE AddTopic
    @TopicName VARCHAR(100)
AS
BEGIN
    --SET NOCOUNT ON;

    -- 1. Trim spaces
    SET @TopicName = LTRIM(RTRIM(@TopicName));

    -- 2. Validate no numbers in TopicName
    IF @TopicName LIKE '%[0-9]%'
    BEGIN
        RAISERROR('Topic name cannot contain numbers.', 16, 1);
        RETURN;
    END;

    -- 3. Check for duplicate topic name
    IF EXISTS (
        SELECT 1
        FROM Topic
        WHERE TopicName = @TopicName
    )
    BEGIN
        RAISERROR('Topic name already exists.', 16, 1);
        RETURN;
    END;

    -- 4. Insert topic
    INSERT INTO Topic (TopicName)
    VALUES (@TopicName);
END;
GO



--7. Insert into Question
CREATE PROCEDURE AddQuestion
    @QuestionText VARCHAR(1000),
    @QuestionType CHAR(1),
    @QuestionMark DECIMAL(5,2),
    @CourseID INT 
AS
BEGIN
    --SET NOCOUNT ON;

    -- 1. Trim QuestionText
    SET @QuestionText = LTRIM(RTRIM(@QuestionText));

    -- 2. Check that Course exists
    IF NOT EXISTS (
        SELECT 1
        FROM Course
        WHERE CourseID = @CourseID
    )
    BEGIN
        RAISERROR('Course does not exist.', 16, 1);
        RETURN;
    END;

    -- 3. Validate QuestionType
    IF @QuestionType NOT IN ('M', 'T')
    BEGIN
        RAISERROR('QuestionType must be either M (MCQ) or T (True/False).', 16, 1);
        RETURN;
    END;

    -- 4. Validate QuestionMark
    IF @QuestionMark < 1 OR @QuestionMark > 10
    BEGIN
        RAISERROR('QuestionMark must be between 1 and 10.', 16, 1);
        RETURN;
    END;

    -- 5. Insert question
    INSERT INTO Question (QuestionText, QuestionType, QuestionMark, CourseID)
    VALUES (@QuestionText, @QuestionType, @QuestionMark, @CourseID);
END;
GO


--8.Insert into Choice
--A table to insert the data at once 
CREATE TYPE ChoiceTableType AS TABLE (
    ChoiceLabel CHAR(1),
    ChoiceText VARCHAR(500),
    IsCorrectChoice BIT
);
GO

CREATE PROCEDURE AddChoice
    @QuestionID INT,
    @Choices ChoiceTableType READONLY
AS
BEGIN

    DECLARE @QuestionType CHAR(1);
    DECLARE @ExpectedCount INT;

    -- 1. Check question exists
    IF NOT EXISTS (SELECT 1 FROM Question WHERE QuestionID = @QuestionID)
    BEGIN
        RAISERROR('Question not found.', 16, 1);
        RETURN;
    END;

    -- 2. Get question type
    SELECT @QuestionType = QuestionType
    FROM Question
    WHERE QuestionID = @QuestionID;

    -- 3. Expected number of choices
    SET @ExpectedCount = CASE
        WHEN @QuestionType = 'M' THEN 4
        WHEN @QuestionType = 'T' THEN 2
    END;

    -- 4. Validate number of choices
    IF (SELECT COUNT(*) FROM @Choices) <> @ExpectedCount
    BEGIN
        RAISERROR('Invalid number of choices for this question type.', 16, 1);
        RETURN;
    END;

    -- 5. Validate exactly one correct choice
    IF (SELECT COUNT(*) FROM @Choices WHERE IsCorrectChoice = 1) <> 1
    BEGIN
        RAISERROR('Exactly one correct choice must be provided.', 16, 1);
        RETURN;
    END;

    -- 6. Validate duplicate choice labels
    IF EXISTS (
        SELECT ChoiceLabel
        FROM @Choices
        GROUP BY ChoiceLabel
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR('Duplicate choice labels are not allowed.', 16, 1);
        RETURN;
    END;


    -- 7. Insert choices
    INSERT INTO Choice (QuestionID, ChoiceLabel, ChoiceText, IsCorrectChoice)
    SELECT
        @QuestionID,
        ChoiceLabel,
        ChoiceText,
        IsCorrectChoice
    FROM @Choices;
END;
GO

/*
example

DECLARE @Choices ChoiceTableType;

INSERT INTO @Choices (ChoiceLabel, ChoiceText, IsCorrectChoice)
VALUES
('A', 'Choice A text', 0),
('B', 'Choice B text', 1),
('C', 'Choice C text', 0),
('D', 'Choice D text', 0);

EXEC AddChoice
    @QuestionID = 3,
    @Choices = @Choices;

*/




--9. Insert into Exam
    
CREATE PROCEDURE AddExam
    @ExamDate DATE,
    @StartTime TIME(7),
    @EndTime TIME(7),
    @TotalMCQQuestions INT,
    @TotalTrueFalseQuestions INT,
    @TotalGrade DECIMAL(5,2),
    @ExamID INT OUTPUT 
AS
BEGIN
    --SET NOCOUNT ON;

    --1. Validate Exam Date is NOT in the past

    IF @ExamDate < CAST(GETDATE() AS DATE)
    BEGIN
        RAISERROR('Exam date cannot be in the past.',16,1);
        RETURN;
    END;


    --2. Validate StartTime < EndTime

    IF @StartTime >= @EndTime
    BEGIN
        RAISERROR('StartTime must be earlier than EndTime.',16,1);
        RETURN;
    END;


    --3. Validate Exam Duration (30 – 120 minutes)

    IF DATEDIFF(MINUTE, @StartTime, @EndTime) < 30
       OR DATEDIFF(MINUTE, @StartTime, @EndTime) > 120
    BEGIN
        RAISERROR(
            'Exam duration must be between 30 and 120 minutes.',
            16,1
        );
        RETURN;
    END;


    --4. Prevent creating an exam that already started today

    if (@ExamDate < cast(getdate() as Date))
		or (@ExamDate = cast(getdate() as Date) and  @StartTime <= cast(Getdate() as Time))
    BEGIN
        RAISERROR(
            'Cannot create an exam that starts in the past.',
            16,1
        );
        RETURN;
    END;


    --5. Validate question counts are NOT negative

    IF @TotalMCQQuestions < 0 OR @TotalTrueFalseQuestions < 0
    BEGIN
        RAISERROR(
            'Question counts cannot be negative.',
            16,1
        );
        RETURN;
    END;


    --6. Validate TOTAL questions = EXACTLY 10

    IF (@TotalMCQQuestions + @TotalTrueFalseQuestions) <> 10
    BEGIN
        RAISERROR(
            'Each exam must have exactly 10 questions (MCQ + True/False).',
            16,1
        );
        RETURN;
    END;


    --7. Insert Exam

   INSERT INTO Exam (ExamDate, StartTime, EndTime, TotalMCQQuestions, TotalTrueFalseQuestions, TotalGrade)
    VALUES (@ExamDate, @StartTime, @EndTime, @TotalMCQQuestions, @TotalTrueFalseQuestions, @TotalGrade);

    SET @ExamID = SCOPE_IDENTITY(); 

END;
GO

    ------------------------------------------------------------------------------


--B) Delete Stored Procedures

--1. Delete from Branch
CREATE PROCEDURE DeleteBranch
    @BranchID INT
AS
BEGIN
    --SET NOCOUNT ON;

    --1. Validate Branch exists

    IF NOT EXISTS (
        SELECT 1
        FROM Branch
        WHERE BranchID = @BranchID
    )
    BEGIN
        RAISERROR('Branch not found.', 16, 1);
        RETURN;
    END;


    --2. Prevent delete if related tracks exist

    IF EXISTS (
        SELECT 1
        FROM Branch_Track
        WHERE BranchID = @BranchID
    )
    BEGIN
        RAISERROR(
            'Cannot delete branch. Delete related records from Branch_Track first.',
            16,
            1
        );
        RETURN;
    END;


    --3. Delete Branch

    DELETE FROM Branch
    WHERE BranchID = @BranchID;
END;
GO


--2. Delete from Track
CREATE PROCEDURE DeleteTrack
    @TrackID INT
AS
BEGIN
    --SET NOCOUNT ON;

    --1. Validate track exists
    IF NOT EXISTS (
        SELECT 1
        FROM Track
        WHERE TrackID = @TrackID
    )
    BEGIN
        RAISERROR('Track not found.', 16, 1);
        RETURN;
    END;

    --2. Check related students
    IF EXISTS (
        SELECT 1
        FROM Student
        WHERE TrackID = @TrackID
    )
    BEGIN
        RAISERROR('Delete related records from Student first.', 16, 1);
        RETURN;
    END;

    --3. Check related branches
    IF EXISTS (
        SELECT 1
        FROM Branch_Track
        WHERE TrackID = @TrackID
    )
    BEGIN
        RAISERROR('Delete related records from Branch_Track first.', 16, 1);
        RETURN;
    END;

    --4. Check related courses
    IF EXISTS (
        SELECT 1
        FROM Track_Course
        WHERE TrackID = @TrackID
    )
    BEGIN
        RAISERROR('Delete related records from Track_Course first.', 16, 1);
        RETURN;
    END;

    --5. Check related instructors
    IF EXISTS (
        SELECT 1
        FROM Track_Instructor
        WHERE TrackID = @TrackID
    )
    BEGIN
        RAISERROR('Delete related records from Track_Instructor first.', 16, 1);
        RETURN;
    END;

    --6. Delete track
    DELETE FROM Track
    WHERE TrackID = @TrackID;
END;
GO


--3. Delete from Instructor
CREATE PROCEDURE DeleteInstructor
    @InstructorID INT
AS
BEGIN
    --SET NOCOUNT ON;

    --1. Validate instructor exists
    IF NOT EXISTS (
        SELECT 1
        FROM Instructor
        WHERE InstructorID = @InstructorID
    )
    BEGIN
        RAISERROR('Instructor not found.', 16, 1);
        RETURN;
    END;

    --2. Check related tracks
    IF EXISTS (
        SELECT 1
        FROM Track_Instructor
        WHERE InstructorID = @InstructorID
    )
    BEGIN
        RAISERROR('Delete related records from Track_Instructor first.', 16, 1);
        RETURN;
    END;

    --3. Check related courses
    IF EXISTS (
        SELECT 1
        FROM Instructor_Course
        WHERE InstructorID = @InstructorID
    )
    BEGIN
        RAISERROR('Delete related records from Instructor_Course first.', 16, 1);
        RETURN;
    END;

    --4. Delete instructor
    DELETE FROM Instructor
    WHERE InstructorID = @InstructorID;
END;
GO



--4. Delete from Student
CREATE PROCEDURE DeleteStudent
    @StudentID INT
AS
BEGIN
    --SET NOCOUNT ON;

    --1. Validate student exists
    IF NOT EXISTS (
        SELECT 1
        FROM Student
        WHERE StudentID = @StudentID
    )
    BEGIN
        RAISERROR('Student not found.', 16, 1);
        RETURN;
    END;

    --2. Check related exams
    IF EXISTS (
        SELECT 1
        FROM Student_Exam
        WHERE StudentID = @StudentID
    )
    BEGIN
        RAISERROR('Delete related records from Student_Exam first.', 16, 1);
        RETURN;
    END;

    --3. Delete student
    DELETE FROM Student
    WHERE StudentID = @StudentID;
END;
GO



--5. Delete from Course
CREATE PROCEDURE DeleteCourse
    @CourseID INT
AS
BEGIN
    --SET NOCOUNT ON;

    --1. Validate course exists
    IF NOT EXISTS (
        SELECT 1
        FROM Course
        WHERE CourseID = @CourseID
    )
    BEGIN
        RAISERROR('Course not found.', 16, 1);
        RETURN;
    END;

    --2. Check related questions
    IF EXISTS (
        SELECT 1
        FROM Question
        WHERE CourseID = @CourseID
    )
    BEGIN
        RAISERROR('Delete related records from Question first.', 16, 1);
        RETURN;
    END;

    --3. Check related tracks
    IF EXISTS (
        SELECT 1
        FROM Track_Course
        WHERE CourseID = @CourseID
    )
    BEGIN
        RAISERROR('Delete related records from Track_Course first.', 16, 1);
        RETURN;
    END;

    --4. Check related instructors
    IF EXISTS (
        SELECT 1
        FROM Instructor_Course
        WHERE CourseID = @CourseID
    )
    BEGIN
        RAISERROR('Delete related records from Instructor_Course first.', 16, 1);
        RETURN;
    END;

    --5. Check related topics
    IF EXISTS (
        SELECT 1
        FROM Course_Topic
        WHERE CourseID = @CourseID
    )
    BEGIN
        RAISERROR('Delete related records from Course_Topic first.', 16, 1);
        RETURN;
    END;

    --6. Delete course
    DELETE FROM Course
    WHERE CourseID = @CourseID;
END;
GO



--6. Delete from Topic
CREATE PROCEDURE DeleteTopic
    @TopicID INT
AS
BEGIN
    --SET NOCOUNT ON;

    --1. Validate topic exists
    IF NOT EXISTS (
        SELECT 1
        FROM Topic
        WHERE TopicID = @TopicID
    )
    BEGIN
        RAISERROR('Topic not found.', 16, 1);
        RETURN;
    END;

    --2. Check related courses
    IF EXISTS (
        SELECT 1
        FROM Course_Topic
        WHERE TopicID = @TopicID
    )
    BEGIN
        RAISERROR('Delete related records from Course_Topic first.', 16, 1);
        RETURN;
    END;

    --3. Delete topic
    DELETE FROM Topic
    WHERE TopicID = @TopicID;
END;
GO



--7. Delete from Question
CREATE PROCEDURE DeleteQuestion
    @QuestionID INT
AS
BEGIN
    --SET NOCOUNT ON;

    --1. Validate question exists
    IF NOT EXISTS (
        SELECT 1
        FROM Question
        WHERE QuestionID = @QuestionID
    )
    BEGIN
        RAISERROR('Question not found.', 16, 1);
        RETURN;
    END;

    --2. Check related choices
    IF EXISTS (
        SELECT 1
        FROM Choice
        WHERE QuestionID = @QuestionID
    )
    BEGIN
        RAISERROR('Delete related records from Choice first.', 16, 1);
        RETURN;
    END;

    --3. Check related student answers
    IF EXISTS (
        SELECT 1
        FROM Student_Answer
        WHERE QuestionID = @QuestionID
    )
    BEGIN
        RAISERROR('Delete related records from Student_Answer first.', 16, 1);
        RETURN;
    END;

    --4. Delete question
    DELETE FROM Question
    WHERE QuestionID = @QuestionID;
END;
GO


--8. Delete from Choice
CREATE PROCEDURE DeleteChoice
    @ChoiceID INT
AS
BEGIN
    --SET NOCOUNT ON;

    --1. Validate choice exists
    IF NOT EXISTS (
        SELECT 1
        FROM Choice
        WHERE ChoiceID = @ChoiceID
    )
    BEGIN
        RAISERROR('Choice not found.', 16, 1);
        RETURN;
    END;

    --2. Check related student answers
    IF EXISTS (
        SELECT 1
        FROM Student_Answer
        WHERE AnswerID = @ChoiceID
    )
    BEGIN
        RAISERROR('Delete related records from Student_Answer first.', 16, 1);
        RETURN;
    END;

    --3. Delete choice
    DELETE FROM Choice
    WHERE ChoiceID = @ChoiceID;
END;
GO


--9. Delete from Exam
CREATE PROCEDURE DeleteExam
    @ExamID INT
AS
BEGIN
    --SET NOCOUNT ON;

    --1. Validate exam exists
    IF NOT EXISTS (
        SELECT 1
        FROM Exam
        WHERE ExamID = @ExamID
    )
    BEGIN
        RAISERROR('Exam not found.', 16, 1);
        RETURN;
    END;

    --2. Check related student exams
    IF EXISTS (
        SELECT 1
        FROM Student_Exam
        WHERE ExamID = @ExamID
    )
    BEGIN
        RAISERROR('Delete related records from Student_Exam first.', 16, 1);
        RETURN;
    END;

    --3. Delete exam
    DELETE FROM Exam
    WHERE ExamID = @ExamID;
END;
GO









--C) Update Stored Procedures

create procedure UpdateBranch
	@BranchId int,
	@BranchName nvarchar(100) = NULL,
	@BranchLocation nvarchar(200) = NULL
as
begin
	declare @IsBranchExist bit = 0;
	declare @IsDuplicateName bit = 0;


	select @IsBranchExist = 1
	from Branch
	where BranchID = @BranchId

	if @IsBranchExist = 0
	begin
		RAISERROR('Branch not found.',16,1)
	return
	end;

	if @BranchName is not null
	begin
		select @IsDuplicateName = 1
		from Branch
		where BranchName = @BranchName
		and BranchID <> @BranchId

		if @IsDuplicateName = 1
		begin
			RAISERROR('Branch name already exists.',16,1)
		return
		end;
	end;

	update Branch
	set BranchName =coalesce(@BranchName, BranchName),
	BranchLocation =coalesce(@BranchLocation, BranchLocation)
	where BranchID = @BranchId
end;
go


create procedure UpdateCourse
	@CourseId int,
	@CourseName nvarchar(100) = NULL,
	@MinPassDegree decimal(5,2) = NULL 
as
begin
	declare @IsCourseExist bit = 0;
	declare @IsDuplicateName bit = 0;
	declare @HasQuestion bit = 0;

	select @IsCourseExist = 1
	from Course
	where CourseID = @CourseId

	if @IsCourseExist = 0
	begin 
		RAISERROR('Course not found.',16,1)
	return;
	end;

	select @HasQuestion = 1
	from Question
	where CourseID = @CourseId;

	if @CourseName is not null
	begin
		select @IsDuplicateName = 1
		from Course
		where CourseName = @CourseName
		and CourseID <> @CourseId

		if @IsDuplicateName = 1
		begin 
			RAISERROR('Course name already exist.',16,1)
		return;
		end;
	end;

	IF @MinPassDegree IS NOT NULL
	   AND (@MinPassDegree < 0 OR @MinPassDegree > 100)
	BEGIN
		RAISERROR('MinPassDegree must be between 0 and 100.', 16, 1);
		RETURN;
	END;


	if @MinPassDegree is not null and @HasQuestion = 1
	begin
		RAISERROR('Cannot update MinPassDegree because questions are already assigned to this course.',16, 1)
	return;
	end;

	update Course
	set CourseName =coalesce(@CourseName, CourseName),
	MinPassDegree = coalesce(@MinPassDegree,MinPassDegree)
	where CourseID = @CourseId
end;
go



create procedure UpdateInstructor
	@InstructorId int,
	@FirstName nvarchar(50) = NULL,
	@LastName nvarchar(50)= NULL,
	@Email nvarchar(100)= NULL,
	@Phone nvarchar(20) = NULL
as
begin
	declare @IsInstructorExist bit = 0;
	declare @IsEmailExist bit = 0;

	select @IsInstructorExist = 1
	from Instructor
	where InstructorID = @InstructorId

	if @IsInstructorExist = 0
	begin 
		RAISERROR('Instructor not found.',16,1)
		return;
	end

	if @Email is not null
	begin
		
		select @IsEmailExist = 1
		from Instructor
		where Email = @Email and InstructorID <> @InstructorId

		if @IsEmailExist = 1
		begin
			RAISERROR('Email already exists.',16,1)
			return;
		end;

		IF @Email NOT LIKE '%_@_%._%'
		BEGIN
			RAISERROR('Invalid email format.', 16, 1);
			RETURN;
		END;

	end;

	IF @FirstName IS NOT NULL
	BEGIN
		IF @FirstName LIKE '%[0-9]%'
		BEGIN
			RAISERROR('First name must not contain numbers.', 16, 1);
			RETURN;
		END;
	END;

	IF @LastName IS NOT NULL
	BEGIN
		IF @LastName LIKE '%[0-9]%'
		BEGIN
			RAISERROR('Last name must not contain numbers.', 16, 1);
			RETURN;
		END;
	END;

	IF @Phone IS NOT NULL
	BEGIN

		SET @Phone = LTRIM(RTRIM(@Phone));


		IF @Phone LIKE '%[^0-9+]%' OR LEN(@Phone) < 10 OR LEN(@Phone) > 15
		BEGIN
			RAISERROR('Phone number must contain only digits (optionally +) and be 10-15 characters long.', 16, 1);
			RETURN;
		END;
	END;


	update Instructor 
	set FirstName =coalesce(@FirstName,FirstName),
	LastName = coalesce(@LastName,LastName),
	Email = coalesce(@Email,Email),
	Phone = coalesce(@Phone,Phone)
	where InstructorID = @InstructorId
end;
go




create procedure UpdateStudent --check the order of the input variables
	@StudentId int,
	@FirstName nvarchar(50) = null,
	@LastName nvarchar(50) = null,
	@Email nvarchar(100) = null,
	@Phone nvarchar(20) = null
as
begin
	declare @IsStudentExist bit = 0;
	declare @IsEmailExist bit = 0;

	select @IsStudentExist = 1
	from Student
	where StudentID = @StudentId

	if @IsStudentExist = 0
	begin
		RAISERROR('Student not found.',16,1)
		return;
	end;
	if @Email is not null
	begin
		select @IsEmailExist = 1
		from Student
		where Email = @Email and StudentID <> @StudentId
		if @IsEmailExist = 1
		begin
			RAISERROR('Email already exists.',16,1)
			return;
		end;

		IF @Email NOT LIKE '%_@_%._%'
		BEGIN
			RAISERROR('Invalid email format.', 16, 1);
			RETURN;
		END;
	end;

	IF @FirstName IS NOT NULL
	BEGIN
		IF @FirstName LIKE '%[0-9]%'
		BEGIN
			RAISERROR('First name must not contain numbers.', 16, 1);
			RETURN;
		END;
	END;

	IF @LastName IS NOT NULL
	BEGIN
		IF @LastName LIKE '%[0-9]%'
		BEGIN
			RAISERROR('Last name must not contain numbers.', 16, 1);
			RETURN;
		END;
	END;

	IF @Phone IS NOT NULL
	BEGIN

		SET @Phone = LTRIM(RTRIM(@Phone));

		IF @Phone LIKE '%[^0-9+]%' OR LEN(@Phone) < 10 OR LEN(@Phone) > 15
		BEGIN
			RAISERROR('Phone number must contain only digits (optionally +) and be 10-15 characters long.', 16, 1);
			RETURN;
		END;
	END;

	

	update Student
	set FirstName =coalesce(@FirstName,FirstName),
	LastName =coalesce( @LastName,LastName),
	Email = coalesce(@Email,Email),
	Phone =coalesce( @Phone,Phone)
	where StudentID = @StudentId
end;
go






create procedure UpdateTrack
    @TrackId int,
	@TrackSupervisorId int = null,
	@TrackName nvarchar(100) = null
as
begin
	declare @IsTrackExist bit = 0;
	declare @IsInstructorExist bit = 0;

	select @IsTrackExist = 1
	from Track
	where TrackID = @TrackId


	if @IsTrackExist = 0
	begin
		RAISERROR('Track not found.',16,1)
		return;
	end;

	if @TrackSupervisorId is not null
	begin
		select @IsInstructorExist = 1
		from Instructor
		where InstructorID = @TrackSupervisorId
		if @IsInstructorExist = 0
		begin
			 RAISERROR('Supervisor (Instructor) not found.',16,1)
			 return;
		end;
	end;

	IF @TrackName IS NOT NULL
	BEGIN
		IF @TrackName LIKE '%[0-9]%'
		BEGIN
			RAISERROR('Track name must not contain numbers.', 16, 1);
			RETURN;
		END;
	END;


	update Track
	set TrackSupervisor = coalesce(@TrackSupervisorId,TrackSupervisor),
	TrackName = coalesce(@TrackName,TrackName)
	where TrackID = @TrackId
end;
go



create procedure UpdateTopic
	@TopicId int,
	@TopicName nvarchar(100) = NULL,
	@CourseId int = NULL
as
begin
	declare @IsTopicExist bit = 0
	declare @ISDuplicateName bit = 0
	declare @IsCourseExist bit = 0

	select @IsTopicExist = 1
	from Topic
	where TopicID = @TopicId

	if @IsTopicExist = 0
	begin
		RAISERROR('Topic not found.',16,1)
	return;
	end;

	if @CourseId is not null
	begin
		Select @IsCourseExist = 1
		from Course
		where CourseId = @CourseId

		if @IsCourseExist = 0
		begin
			RAISERROR('Course not found.',16,1)
			return;
		end;
	end;


	if @TopicName is not null and @CourseId is not null
	begin
		select @ISDuplicateName = 1
		from Topic t join Course_Topic ct
		on t.TopicID = ct.TopicID
		where t.TopicName = @TopicName
		and ct.CourseID = @CourseId
		and t.TopicID <> @TopicId

		if @ISDuplicateName = 1
		begin
			RAISERROR('Topic name already exists for this course.',16,1)
		return;
		end;
	end

	IF @TopicName IS NOT NULL
	BEGIN
		IF @TopicName LIKE '%[0-9]%'
		BEGIN
			RAISERROR('Topic name must not contain numbers.', 16, 1);
			RETURN;
		END;
	END;
	
	update Topic 
	set TopicName =coalesce(@TopicName,TopicName)
	where TopicID = @TopicId
end;
go



create procedure UpdateExam      
	@ExamId int,
	@ExamDate date = null,
	@StartTime time(7) = null,
	@EndTime time(7) = null,
	@TotalMCQQuestions int = null,
	@TotalTrueFalseQuestions int = null
as
begin
	declare @ExamStart bit = 0
	declare @ExamNewDate bit = 0
	declare @IsExamExist bit = 0
	declare @IsTimeValid bit = 0;

	if @StartTime is not null and @EndTime is not null
	begin
		if @StartTime >= @EndTime 
		set @IsTimeValid = 1;

		if @IsTimeValid = 1
		begin
			RAISERROR('StartTime must be earlier than EndTime.',16,1);
		return;
		end;

		if DATEDIFF(MINUTE, @StartTime, @EndTime) < 30 OR DATEDIFF(MINUTE, @StartTime, @EndTime) > 120 --built-in function that calculates the difference between two dates or times in a specific unit that we decided
		begin
			 RAISERROR('The difference between StartTime and EndTime must be between 30 minutes and 120 minutes',16,1);
		return;
		end;
	end



	select @IsExamExist = 1
	from Exam
	where ExamID = @ExamId

	if @IsExamExist = 0
	begin
		RAISERROR('Exam not found.',16,1);
	return;
	end;

	if @ExamDate is not null and @StartTime is not null
  begin
		if (@ExamDate < cast(getdate() as Date))
		or (@ExamDate = cast(getdate() as Date) and  @StartTime <= cast(Getdate() as Time))
		begin
			set @ExamNewDate = 1
		end;
	if @ExamNewDate = 1
	begin
		RAISERROR('Cannot update exam to a past date/time.',16,1);
    return;
	end;
  end	

	select @ExamStart = 1
	from Exam
	where ExamID = @ExamId
	and(ExamDate < cast(getdate() as Date)
	or (ExamDate = cast(getdate() as Date) and  StartTime < cast(Getdate() as Time)));

	if @ExamStart = 1
	begin
		RAISERROR('Exam has already started. Update not allowed.',16,1);
		return;
	end;


	IF EXISTS (
		SELECT 1
		FROM Exam_Question
		WHERE ExamID = @ExamId
	)
	AND (@TotalMCQQuestions IS NOT NULL OR @TotalTrueFalseQuestions IS NOT NULL)
	BEGIN

		SET @TotalMCQQuestions = NULL;
		SET @TotalTrueFalseQuestions = NULL;

		RAISERROR(
			'Can not update Total MCQ or Total T/F as the exam already has assigned questions.',10,1); -- informational (warning)
	END;


	update Exam
	set ExamDate =coalesce(@ExamDate,ExamDate),
	StartTime = coalesce(@StartTime,StartTime),
	EndTime = coalesce(@EndTime, EndTime),
	TotalMCQQuestions = coalesce(@TotalMCQQuestions,TotalMCQQuestions),
	TotalTrueFalseQuestions = coalesce(@TotalTrueFalseQuestions,TotalTrueFalseQuestions)
	where ExamID = @ExamId
end;
go




create procedure UpdateQuestion
	@QuestionId int,
	@QuestionText nvarchar(1000) = null,
	@QuestionMark decimal(5,2) = null
as
begin

	declare @IsQuestionExist bit = 0


	select @IsQuestionExist = 1
	from Question
	where QuestionID = @QuestionId;

	if @IsQuestionExist = 0
	begin
		RAISERROR('Question not found.',16,1);
    return;
	end;


	IF EXISTS (
		SELECT 1
		FROM Exam_Question eq
		JOIN Exam e ON e.ExamID = eq.ExamID
		WHERE eq.QuestionID = @QuestionID
		  AND ( e.ExamDate < CAST(GETDATE() AS DATE) 
		  OR (e.ExamDate = CAST(GETDATE() AS DATE) AND e.StartTime <= CAST(GETDATE() AS TIME))
		  )
	)
	BEGIN
		RAISERROR('Exam has already started. Question update not allowed.',16,1);
		RETURN;
	END;

	IF EXISTS (
		SELECT 1
		FROM Exam_Question
		WHERE QuestionID = @QuestionID
	)
	AND @QuestionMark IS NOT NULL
	BEGIN
		SET @QuestionMark = NULL;
		RAISERROR('Can not update question mark, question is already assigned to an exam, text is updated successfully.',10,1);
	END;

	
	update Question
	set QuestionText =coalesce(@QuestionText,QuestionText),
	QuestionMark = coalesce(@QuestionMark,QuestionMark)
	where QuestionID = @QuestionId 
end;
go



CREATE TYPE ChoicesTableType AS TABLE (
    ChoiceLabel CHAR(1),
    ChoiceText VARCHAR(500),
    IsCorrectChoice BIT
);
GO

CREATE PROCEDURE UpdateChoice
    @QuestionID INT,
    @Choices ChoicesTableType READONLY
AS
BEGIN

    DECLARE @QuestionType CHAR(1);
    DECLARE @ExpectedCount INT;


    --1. Check question exists

    IF NOT EXISTS (
        SELECT 1
        FROM Question
        WHERE QuestionID = @QuestionID
    )
    BEGIN
        RAISERROR('Question not found.', 16, 1);
        RETURN;
    END;


	--2. Question already has choices
	IF NOT EXISTS (
		SELECT 1
		FROM Choice
		WHERE QuestionID = @QuestionID
	)
	BEGIN
		RAISERROR(
			'Cannot update choices. This question has no choices yet.',
			16,
			1
		);
		RETURN;
	END;


    --3. Block update if question is in started exam

    IF EXISTS (
        SELECT 1
        FROM Exam_Question eq
        JOIN Exam e ON e.ExamID = eq.ExamID
        WHERE eq.QuestionID = @QuestionID
          AND (
                e.ExamDate < CAST(GETDATE() AS DATE)
             OR (e.ExamDate = CAST(GETDATE() AS DATE)
                 AND e.StartTime <= CAST(GETDATE() AS TIME))
          )
    )
    BEGIN
        RAISERROR(
            'Exam has already started. Choice update not allowed.',
            16,
            1
        );
        RETURN;
    END;


    --4. Get question type

    SELECT @QuestionType = QuestionType
    FROM Question
    WHERE QuestionID = @QuestionID;

    SET @ExpectedCount = CASE
        WHEN @QuestionType = 'M' THEN 4
        WHEN @QuestionType = 'T' THEN 2
    END;


    --5. Validate number of choices

    IF (SELECT COUNT(*) FROM @Choices) <> @ExpectedCount
    BEGIN
        RAISERROR('Invalid number of choices for this question type.', 16, 1);
        RETURN;
    END;


    --6. Validate exactly one correct choice

    IF (SELECT COUNT(*) FROM @Choices WHERE IsCorrectChoice = 1) <> 1
    BEGIN
        RAISERROR('Exactly one correct choice must be provided.', 16, 1);
        RETURN;
    END;


    --7. Validate duplicate choice labels 

    IF EXISTS (
        SELECT ChoiceLabel
        FROM @Choices
        GROUP BY ChoiceLabel
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR('Duplicate choice labels are not allowed.', 16, 1);
        RETURN;
    END;


    --8. Update choices

    UPDATE ch
    SET
        ch.ChoiceText = c.ChoiceText,
        ch.IsCorrectChoice = c.IsCorrectChoice
    FROM Choice ch
    JOIN @Choices c
        ON ch.QuestionID = @QuestionID
       AND ch.ChoiceLabel = c.ChoiceLabel;
END;
GO

/*--how to use	
-- Declare a variable of your table type
DECLARE @UpdatedChoices ChoiceTableType;

-- Insert the updated choice data
INSERT INTO @UpdatedChoices (ChoiceLabel, ChoiceText, IsCorrectChoice)
VALUES
('A', 'New Option A', 0),
('B', 'New Option B', 1),  -- correct choice
('C', 'New Option C', 0),
('D', 'New Option D', 0);

-- Update choices for question with ID = 5
EXEC UpdateChoice
    @QuestionID = 5,
    @Choices = @UpdatedChoices;

*/


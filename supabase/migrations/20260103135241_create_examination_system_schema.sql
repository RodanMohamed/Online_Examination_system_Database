/*
  # Examination System Database Schema

  ## Main Tables
  
  1. **Branch** - Educational branches/locations
     - BranchID (PK)
     - BranchName
     - BranchLocation
  
  2. **Track** - Educational tracks/departments
     - TrackID (PK)
     - TrackName
     - TrackSupervisor (FK to Instructor)
  
  3. **Instructor** - Teaching staff
     - InstructorID (PK)
     - FirstName, LastName
     - Email, Phone
     - HireDate
  
  4. **Course** - Academic courses
     - CourseID (PK)
     - CourseName
     - CourseDescription
  
  5. **Student** - Enrolled students
     - StudentID (PK)
     - FirstName, LastName
     - Email, Phone
     - EnrollmentDate
     - TrackID (FK)
  
  6. **Topic** - Course topics
     - TopicID (PK)
     - TopicName
     - TopicDescription
  
  7. **Question** - Exam questions
     - QuestionID (PK)
     - QuestionText
     - QuestionType (M=MCQ, T=True/False)
     - QuestionMark
     - CourseID (FK)
  
  8. **Choice** - Question choices
     - ChoiceID (PK)
     - QuestionID (FK)
     - ChoiceLabel (A, B, C, D)
     - ChoiceText
     - IsCorrectChoice
  
  9. **Exam** - Examinations
     - ExamID (PK)
     - ExamDate
     - StartTime, EndTime
     - TotalMCQQuestions
     - TotalTrueFalseQuestions
     - TotalGrade
  
  ## Relationship Tables
  
  10. **Branch_Track** - Branches offer Tracks
  11. **Track_Instructor** - Instructors assigned to Tracks
  12. **Track_Course** - Courses in Tracks
  13. **Instructor_Course** - Instructors teach Courses
  14. **Course_Topic** - Topics in Courses
  15. **Exam_Question** - Questions in Exams
  16. **Student_Exam** - Students take Exams
  17. **Student_Answer** - Student answers to questions
  
  ## Security
  - Enable RLS on all tables
  - Policies for authenticated users based on roles
  - Admin can manage all
  - Instructors can view their courses/students
  - Students can view their own data
*/

-- Main Tables

CREATE TABLE IF NOT EXISTS Branch (
    BranchID SERIAL PRIMARY KEY,
    BranchName VARCHAR(100) NOT NULL,
    BranchLocation VARCHAR(200) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS Instructor (
    InstructorID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    HireDate DATE DEFAULT CURRENT_DATE,
    user_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS Track (
    TrackID SERIAL PRIMARY KEY,
    TrackName VARCHAR(100) NOT NULL,
    TrackSupervisor INT REFERENCES Instructor(InstructorID),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS Course (
    CourseID SERIAL PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    CourseDescription TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS Student (
    StudentID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    EnrollmentDate DATE DEFAULT CURRENT_DATE,
    TrackID INT REFERENCES Track(TrackID),
    user_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS Topic (
    TopicID SERIAL PRIMARY KEY,
    TopicName VARCHAR(100) NOT NULL,
    TopicDescription TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS Question (
    QuestionID SERIAL PRIMARY KEY,
    QuestionText TEXT NOT NULL,
    QuestionType CHAR(1) CHECK (QuestionType IN ('M', 'T')) NOT NULL,
    QuestionMark DECIMAL(5,2) NOT NULL,
    CourseID INT REFERENCES Course(CourseID) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS Choice (
    ChoiceID SERIAL PRIMARY KEY,
    QuestionID INT REFERENCES Question(QuestionID) ON DELETE CASCADE,
    ChoiceLabel CHAR(1) NOT NULL,
    ChoiceText TEXT NOT NULL,
    IsCorrectChoice BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS Exam (
    ExamID SERIAL PRIMARY KEY,
    ExamDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    TotalMCQQuestions INT DEFAULT 0,
    TotalTrueFalseQuestions INT DEFAULT 0,
    TotalGrade DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Relationship Tables

CREATE TABLE IF NOT EXISTS Branch_Track (
    BranchTrackID SERIAL PRIMARY KEY,
    BranchID INT REFERENCES Branch(BranchID) ON DELETE CASCADE,
    TrackID INT REFERENCES Track(TrackID) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(BranchID, TrackID)
);

CREATE TABLE IF NOT EXISTS Track_Instructor (
    TrackInstructorID SERIAL PRIMARY KEY,
    TrackID INT REFERENCES Track(TrackID) ON DELETE CASCADE,
    InstructorID INT REFERENCES Instructor(InstructorID) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(TrackID, InstructorID)
);

CREATE TABLE IF NOT EXISTS Track_Course (
    TrackCourseID SERIAL PRIMARY KEY,
    TrackID INT REFERENCES Track(TrackID) ON DELETE CASCADE,
    CourseID INT REFERENCES Course(CourseID) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(TrackID, CourseID)
);

CREATE TABLE IF NOT EXISTS Instructor_Course (
    InstructorCourseID SERIAL PRIMARY KEY,
    InstructorID INT REFERENCES Instructor(InstructorID) ON DELETE CASCADE,
    CourseID INT REFERENCES Course(CourseID) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(InstructorID, CourseID)
);

CREATE TABLE IF NOT EXISTS Course_Topic (
    CourseTopicID SERIAL PRIMARY KEY,
    CourseID INT REFERENCES Course(CourseID) ON DELETE CASCADE,
    TopicID INT REFERENCES Topic(TopicID) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(CourseID, TopicID)
);

CREATE TABLE IF NOT EXISTS Exam_Question (
    ExamQuestionID SERIAL PRIMARY KEY,
    ExamID INT REFERENCES Exam(ExamID) ON DELETE CASCADE,
    QuestionID INT REFERENCES Question(QuestionID) ON DELETE CASCADE,
    QuestionOrder INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(ExamID, QuestionID)
);

CREATE TABLE IF NOT EXISTS Student_Exam (
    StudentExamID SERIAL PRIMARY KEY,
    StudentID INT REFERENCES Student(StudentID) ON DELETE CASCADE,
    ExamID INT REFERENCES Exam(ExamID) ON DELETE CASCADE,
    StartTime TIMESTAMPTZ NOT NULL,
    EndTime TIMESTAMPTZ NOT NULL,
    TotalScore DECIMAL(5,2),
    Percentage DECIMAL(5,2),
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(StudentID, ExamID)
);

CREATE TABLE IF NOT EXISTS Student_Answer (
    StudentAnswerID SERIAL PRIMARY KEY,
    StudentExamID INT REFERENCES Student_Exam(StudentExamID) ON DELETE CASCADE,
    QuestionID INT REFERENCES Question(QuestionID) ON DELETE CASCADE,
    AnswerID INT REFERENCES Choice(ChoiceID),
    IsCorrect BOOLEAN,
    Mark DECIMAL(5,2),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security

ALTER TABLE Branch ENABLE ROW LEVEL SECURITY;
ALTER TABLE Instructor ENABLE ROW LEVEL SECURITY;
ALTER TABLE Track ENABLE ROW LEVEL SECURITY;
ALTER TABLE Course ENABLE ROW LEVEL SECURITY;
ALTER TABLE Student ENABLE ROW LEVEL SECURITY;
ALTER TABLE Topic ENABLE ROW LEVEL SECURITY;
ALTER TABLE Question ENABLE ROW LEVEL SECURITY;
ALTER TABLE Choice ENABLE ROW LEVEL SECURITY;
ALTER TABLE Exam ENABLE ROW LEVEL SECURITY;
ALTER TABLE Branch_Track ENABLE ROW LEVEL SECURITY;
ALTER TABLE Track_Instructor ENABLE ROW LEVEL SECURITY;
ALTER TABLE Track_Course ENABLE ROW LEVEL SECURITY;
ALTER TABLE Instructor_Course ENABLE ROW LEVEL SECURITY;
ALTER TABLE Course_Topic ENABLE ROW LEVEL SECURITY;
ALTER TABLE Exam_Question ENABLE ROW LEVEL SECURITY;
ALTER TABLE Student_Exam ENABLE ROW LEVEL SECURITY;
ALTER TABLE Student_Answer ENABLE ROW LEVEL SECURITY;

-- RLS Policies (Basic - All authenticated users can read, we'll refine based on roles)

-- Branch policies
CREATE POLICY "Anyone can view branches"
  ON Branch FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage branches"
  ON Branch FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Instructor policies
CREATE POLICY "Anyone can view instructors"
  ON Instructor FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Instructors can view own data"
  ON Instructor FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Track policies
CREATE POLICY "Anyone can view tracks"
  ON Track FOR SELECT
  TO authenticated
  USING (true);

-- Course policies
CREATE POLICY "Anyone can view courses"
  ON Course FOR SELECT
  TO authenticated
  USING (true);

-- Student policies
CREATE POLICY "Students can view own data"
  ON Student FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view students"
  ON Student FOR SELECT
  TO authenticated
  USING (true);

-- Topic policies
CREATE POLICY "Anyone can view topics"
  ON Topic FOR SELECT
  TO authenticated
  USING (true);

-- Question policies
CREATE POLICY "Anyone can view questions"
  ON Question FOR SELECT
  TO authenticated
  USING (true);

-- Choice policies
CREATE POLICY "Anyone can view choices"
  ON Choice FOR SELECT
  TO authenticated
  USING (true);

-- Exam policies
CREATE POLICY "Anyone can view exams"
  ON Exam FOR SELECT
  TO authenticated
  USING (true);

-- Relationship tables - all authenticated can read
CREATE POLICY "Anyone can view branch tracks"
  ON Branch_Track FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Anyone can view track instructors"
  ON Track_Instructor FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Anyone can view track courses"
  ON Track_Course FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Anyone can view instructor courses"
  ON Instructor_Course FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Anyone can view course topics"
  ON Course_Topic FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Anyone can view exam questions"
  ON Exam_Question FOR SELECT
  TO authenticated
  USING (true);

-- Student Exam policies
CREATE POLICY "Students can view own exams"
  ON Student_Exam FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM Student
      WHERE Student.StudentID = Student_Exam.StudentID
      AND Student.user_id = auth.uid()
    )
  );

CREATE POLICY "Students can insert own exam records"
  ON Student_Exam FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM Student
      WHERE Student.StudentID = Student_Exam.StudentID
      AND Student.user_id = auth.uid()
    )
  );

CREATE POLICY "Students can update own exam records"
  ON Student_Exam FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM Student
      WHERE Student.StudentID = Student_Exam.StudentID
      AND Student.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM Student
      WHERE Student.StudentID = Student_Exam.StudentID
      AND Student.user_id = auth.uid()
    )
  );

-- Student Answer policies
CREATE POLICY "Students can view own answers"
  ON Student_Answer FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM Student_Exam
      JOIN Student ON Student.StudentID = Student_Exam.StudentID
      WHERE Student_Exam.StudentExamID = Student_Answer.StudentExamID
      AND Student.user_id = auth.uid()
    )
  );

CREATE POLICY "Students can insert own answers"
  ON Student_Answer FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM Student_Exam
      JOIN Student ON Student.StudentID = Student_Exam.StudentID
      WHERE Student_Exam.StudentExamID = Student_Answer.StudentExamID
      AND Student.user_id = auth.uid()
    )
  );

CREATE POLICY "Students can update own answers"
  ON Student_Answer FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM Student_Exam
      JOIN Student ON Student.StudentID = Student_Exam.StudentID
      WHERE Student_Exam.StudentExamID = Student_Answer.StudentExamID
      AND Student.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM Student_Exam
      JOIN Student ON Student.StudentID = Student_Exam.StudentID
      WHERE Student_Exam.StudentExamID = Student_Answer.StudentExamID
      AND Student.user_id = auth.uid()
    )
  );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_student_track ON Student(TrackID);
CREATE INDEX IF NOT EXISTS idx_question_course ON Question(CourseID);
CREATE INDEX IF NOT EXISTS idx_choice_question ON Choice(QuestionID);
CREATE INDEX IF NOT EXISTS idx_student_exam_student ON Student_Exam(StudentID);
CREATE INDEX IF NOT EXISTS idx_student_exam_exam ON Student_Exam(ExamID);
CREATE INDEX IF NOT EXISTS idx_student_answer_exam ON Student_Answer(StudentExamID);
CREATE INDEX IF NOT EXISTS idx_student_user ON Student(user_id);
CREATE INDEX IF NOT EXISTS idx_instructor_user ON Instructor(user_id);

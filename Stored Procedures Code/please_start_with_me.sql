--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--------------------------------------------------------------------------------------------------------------------
-- NOTE : This is already done , don't excute it again (from line 7 to line 445) , please go directly to line 448 :)
--------------------------------------------------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-- Exam 1: C# Programming
EXEC Generate_Exam
    @CourseName = 'C# Programming',
    @ExamDate = '2026-01-05',
    @StartTime = '09:00',
    @EndTime = '11:00',
    @TotalMCQQuestions = 6,
    @TotalTrueFalseQuestions = 4;

-- Exam 2: ASP.NET Core
EXEC Generate_Exam
    @CourseName = 'ASP.NET Core',
    @ExamDate = '2026-01-06',
    @StartTime = '09:00',
    @EndTime = '11:00',
    @TotalMCQQuestions = 7,
    @TotalTrueFalseQuestions = 3;

-- Exam 3: SQL Server
EXEC Generate_Exam
    @CourseName = 'SQL Server',
    @ExamDate = '2026-01-07',
    @StartTime = '09:00',
    @EndTime = '11:00',
    @TotalMCQQuestions = 5,
    @TotalTrueFalseQuestions = 5;

-- Exam 4: JavaScript
EXEC Generate_Exam
    @CourseName = 'JavaScript',
    @ExamDate = '2026-01-08',
    @StartTime = '09:00',
    @EndTime = '11:00',
    @TotalMCQQuestions = 4,
    @TotalTrueFalseQuestions = 6;

-- Exam 5: HTML & CSS
EXEC Generate_Exam
    @CourseName = 'HTML & CSS',
    @ExamDate = '2026-01-09',
    @StartTime = '09:00',
    @EndTime = '11:00',
    @TotalMCQQuestions = 3,
    @TotalTrueFalseQuestions = 7;



--///////////////////////////////////////////////////////// Link Students with Exams 

-- Declare variables for exam start/end for each exam
DECLARE 
    @ExamStart1 DATETIME, @ExamEnd1 DATETIME,
    @ExamStart2 DATETIME, @ExamEnd2 DATETIME,
    @ExamStart3 DATETIME, @ExamEnd3 DATETIME,
    @ExamStart4 DATETIME, @ExamEnd4 DATETIME,
    @ExamStart5 DATETIME, @ExamEnd5 DATETIME;

-- Get Exam 1 times
SELECT 
    @ExamStart1 = CAST(ExamDate AS DATETIME) + CAST(StartTime AS DATETIME),
    @ExamEnd1   = CAST(ExamDate AS DATETIME) + CAST(EndTime AS DATETIME)
FROM Exam
WHERE ExamID = 1;

-- Get Exam 2 times
SELECT 
    @ExamStart2 = CAST(ExamDate AS DATETIME) + CAST(StartTime AS DATETIME),
    @ExamEnd2   = CAST(ExamDate AS DATETIME) + CAST(EndTime AS DATETIME)
FROM Exam
WHERE ExamID = 2;

-- Get Exam 3 times
SELECT 
    @ExamStart3 = CAST(ExamDate AS DATETIME) + CAST(StartTime AS DATETIME),
    @ExamEnd3   = CAST(ExamDate AS DATETIME) + CAST(EndTime AS DATETIME)
FROM Exam
WHERE ExamID = 3;

-- Get Exam 4 times
SELECT 
    @ExamStart4 = CAST(ExamDate AS DATETIME) + CAST(StartTime AS DATETIME),
    @ExamEnd4   = CAST(ExamDate AS DATETIME) + CAST(EndTime AS DATETIME)
FROM Exam
WHERE ExamID = 4;

-- Get Exam 5 times
SELECT 
    @ExamStart5 = CAST(ExamDate AS DATETIME) + CAST(StartTime AS DATETIME),
    @ExamEnd5   = CAST(ExamDate AS DATETIME) + CAST(EndTime AS DATETIME)
FROM Exam
WHERE ExamID = 5;

-- Adjust start/end times (+5 min for start, -5 min for end)
DECLARE 
    @StudentStart1 DATETIME = DATEADD(MINUTE, 5, @ExamStart1),
    @StudentEnd1   DATETIME = DATEADD(MINUTE, -5, @ExamEnd1),
    @StudentStart2 DATETIME = DATEADD(MINUTE, 5, @ExamStart2),
    @StudentEnd2   DATETIME = DATEADD(MINUTE, -5, @ExamEnd2),
    @StudentStart3 DATETIME = DATEADD(MINUTE, 5, @ExamStart3),
    @StudentEnd3   DATETIME = DATEADD(MINUTE, -5, @ExamEnd3),
    @StudentStart4 DATETIME = DATEADD(MINUTE, 5, @ExamStart4),
    @StudentEnd4   DATETIME = DATEADD(MINUTE, -5, @ExamEnd4),
    @StudentStart5 DATETIME = DATEADD(MINUTE, 5, @ExamStart5),
    @StudentEnd5   DATETIME = DATEADD(MINUTE, -5, @ExamEnd5);

-- Insert students for Exam 1
EXEC AddStudentExam 21, 1, @StudentStart1, @StudentEnd1;
EXEC AddStudentExam 22, 1, @StudentStart1, @StudentEnd1;
EXEC AddStudentExam 23, 1, @StudentStart1, @StudentEnd1;
EXEC AddStudentExam 31, 1, @StudentStart1, @StudentEnd1;
EXEC AddStudentExam 32, 1, @StudentStart1, @StudentEnd1;

-- Insert students for Exam 2
EXEC AddStudentExam 33, 2, @StudentStart2, @StudentEnd2;
EXEC AddStudentExam 85, 2, @StudentStart2, @StudentEnd2;
EXEC AddStudentExam 86, 2, @StudentStart2, @StudentEnd2;
EXEC AddStudentExam 87, 2, @StudentStart2, @StudentEnd2;

-- Insert students for Exam 3
EXEC AddStudentExam 88, 3, @StudentStart3, @StudentEnd3;
EXEC AddStudentExam 89, 3, @StudentStart3, @StudentEnd3;
EXEC AddStudentExam 90, 3, @StudentStart3, @StudentEnd3;
EXEC AddStudentExam 91, 3, @StudentStart3, @StudentEnd3;

-- Insert students for Exam 4
EXEC AddStudentExam 92, 4, @StudentStart4, @StudentEnd4;
EXEC AddStudentExam 93, 4, @StudentStart4, @StudentEnd4;
EXEC AddStudentExam 94, 4, @StudentStart4, @StudentEnd4;
EXEC AddStudentExam 95, 4, @StudentStart4, @StudentEnd4;

-- Insert students for Exam 5
EXEC AddStudentExam 96, 5, @StudentStart5, @StudentEnd5;
EXEC AddStudentExam 97, 5, @StudentStart5, @StudentEnd5;
EXEC AddStudentExam 98, 5, @StudentStart5, @StudentEnd5;
EXEC AddStudentExam 99, 5, @StudentStart5, @StudentEnd5;


----- Extra Exams For Student 21 to test the second report 
EXEC AddStudentExam 21, 2, @StudentStart2, @StudentEnd2;
EXEC AddStudentExam 21, 3, @StudentStart3, @StudentEnd3;

-- ///////////////////////////////////////////////////////////// add student answers

-- StudentExamID 1 → Student 21, Exam 1
EXEC AddStudentAnswer 21, 1, 226, 23;  -- correct (:)
EXEC AddStudentAnswer 21, 1, 221, 2;   -- wrong (B)
EXEC AddStudentAnswer 21, 1, 222, 5;   -- wrong (A)
EXEC AddStudentAnswer 21, 1, 229, 34;  -- correct (B)
EXEC AddStudentAnswer 21, 1, 228, 32;  -- correct (C)
EXEC AddStudentAnswer 21, 1, 227, 28;  -- correct (D)
EXEC AddStudentAnswer 21, 1, 238, 55;  -- wrong (A)
EXEC AddStudentAnswer 21, 1, 236, 51;  -- correct (A)
EXEC AddStudentAnswer 21, 1, 233, 46;  -- wrong (B)
EXEC AddStudentAnswer 21, 1, 234, 48;  -- correct (B)

-- StudentExamID 2 → Student 22, Exam 1
EXEC AddStudentAnswer 22, 1, 226, 22;  -- wrong (B)
EXEC AddStudentAnswer 22, 1, 221, 1;   -- correct (A)
EXEC AddStudentAnswer 22, 1, 222, 7;   -- correct (C)
EXEC AddStudentAnswer 22, 1, 229, 33;  -- wrong (A)
EXEC AddStudentAnswer 22, 1, 228, 29;  -- wrong (A)
EXEC AddStudentAnswer 22, 1, 227, 27;  -- wrong (C)
EXEC AddStudentAnswer 22, 1, 238, 56;  -- correct (B)
EXEC AddStudentAnswer 22, 1, 236, 52;  -- wrong (B)
EXEC AddStudentAnswer 22, 1, 233, 45;  -- correct (A)
EXEC AddStudentAnswer 22, 1, 234, 47;  -- wrong (A)

-- StudentExamID 3 → Student 23, Exam 1
EXEC AddStudentAnswer 23, 1, 226, 21;  -- wrong (A)
EXEC AddStudentAnswer 23, 1, 221, 3;   -- wrong (C)
EXEC AddStudentAnswer 23, 1, 222, 7;   -- correct (C)
EXEC AddStudentAnswer 23, 1, 229, 34;  -- correct (B)
EXEC AddStudentAnswer 23, 1, 228, 30;  -- wrong (B)
EXEC AddStudentAnswer 23, 1, 227, 28;  -- correct (D)
EXEC AddStudentAnswer 23, 1, 238, 56;  -- correct (B)
EXEC AddStudentAnswer 23, 1, 236, 51;  -- correct (A)
EXEC AddStudentAnswer 23, 1, 233, 46;  -- wrong (B)
EXEC AddStudentAnswer 23, 1, 234, 48;  -- correct (B)

-- StudentExamID 4 → Student 31, Exam 1
EXEC AddStudentAnswer 31, 1, 226, 24;  -- wrong (D)
EXEC AddStudentAnswer 31, 1, 221, 1;   -- correct (A)
EXEC AddStudentAnswer 31, 1, 222, 6;   -- wrong (B)
EXEC AddStudentAnswer 31, 1, 229, 36;  -- wrong (D)
EXEC AddStudentAnswer 31, 1, 228, 31;  -- correct (C)
EXEC AddStudentAnswer 31, 1, 227, 25;  -- wrong (A)
EXEC AddStudentAnswer 31, 1, 238, 55;  -- wrong (A)
EXEC AddStudentAnswer 31, 1, 236, 52;  -- wrong (B)
EXEC AddStudentAnswer 31, 1, 233, 45;  -- correct (A)
EXEC AddStudentAnswer 31, 1, 234, 48;  -- correct (B)

-- StudentExamID 5 → Student 32, Exam 1
EXEC AddStudentAnswer 32, 1, 226, 23;  -- correct (C)
EXEC AddStudentAnswer 32, 1, 221, 4;   -- wrong (D)
EXEC AddStudentAnswer 32, 1, 222, 5;   -- wrong (A)
EXEC AddStudentAnswer 32, 1, 229, 35;  -- wrong (C)
EXEC AddStudentAnswer 32, 1, 228, 32;  -- correct (C)
EXEC AddStudentAnswer 32, 1, 227, 28;  -- correct (D)
EXEC AddStudentAnswer 32, 1, 238, 56;  -- correct (B)
EXEC AddStudentAnswer 32, 1, 236, 51;  -- correct (A)
EXEC AddStudentAnswer 32, 1, 233, 46;  -- wrong (B)
EXEC AddStudentAnswer 32, 1, 234, 47;  -- wrong (A)


-- StudentExamID 6 → Student 33, Exam 2
EXEC AddStudentAnswer 33, 2, 242, 66;  -- correct (B)
EXEC AddStudentAnswer 33, 2, 247, 86;  -- correct (B)
EXEC AddStudentAnswer 33, 2, 249, 96;  -- correct (D)
EXEC AddStudentAnswer 33, 2, 241, 62;  -- wrong (B)
EXEC AddStudentAnswer 33, 2, 245, 79;  -- correct (C)
EXEC AddStudentAnswer 33, 2, 246, 83;  -- wrong (C)
EXEC AddStudentAnswer 33, 2, 248, 91;  -- correct (C)
EXEC AddStudentAnswer 33, 2, 255, 109; -- correct (A)
EXEC AddStudentAnswer 33, 2, 253, 106; -- wrong (B)
EXEC AddStudentAnswer 33, 2, 251, 101; -- correct (A)

-- StudentExamID 7 → Student 85, Exam 2
EXEC AddStudentAnswer 85, 2, 242, 65;  -- wrong (A)
EXEC AddStudentAnswer 85, 2, 247, 87;  -- wrong (C)
EXEC AddStudentAnswer 85, 2, 249, 96;  -- correct (D)
EXEC AddStudentAnswer 85, 2, 241, 61;  -- correct (A)
EXEC AddStudentAnswer 85, 2, 245, 78;  -- wrong (B)
EXEC AddStudentAnswer 85, 2, 246, 84;  -- correct (D)
EXEC AddStudentAnswer 85, 2, 248, 92;  -- wrong (D)
EXEC AddStudentAnswer 85, 2, 255, 110; -- wrong (B)
EXEC AddStudentAnswer 85, 2, 253, 105; -- correct (A)
EXEC AddStudentAnswer 85, 2, 251, 102; -- wrong (B)

-- StudentExamID 8 → Student 86, Exam 2
EXEC AddStudentAnswer 86, 2, 242, 67;  -- wrong (C)
EXEC AddStudentAnswer 86, 2, 247, 86;  -- correct (B)
EXEC AddStudentAnswer 86, 2, 249, 94;  -- wrong (B)
EXEC AddStudentAnswer 86, 2, 241, 63;  -- wrong (C)
EXEC AddStudentAnswer 86, 2, 245, 80;  -- wrong (D)
EXEC AddStudentAnswer 86, 2, 246, 84;  -- correct (D)
EXEC AddStudentAnswer 86, 2, 248, 91;  -- correct (C)
EXEC AddStudentAnswer 86, 2, 255, 109; -- correct (A)
EXEC AddStudentAnswer 86, 2, 253, 106; -- wrong (B)
EXEC AddStudentAnswer 86, 2, 251, 101; -- correct (A)

-- StudentExamID 9 → Student 87, Exam 2
EXEC AddStudentAnswer 87, 2, 242, 66;  -- correct (B)
EXEC AddStudentAnswer 87, 2, 247, 85;  -- wrong (A)
EXEC AddStudentAnswer 87, 2, 249, 96;  -- correct (D)
EXEC AddStudentAnswer 87, 2, 241, 61;  -- correct (A)
EXEC AddStudentAnswer 87, 2, 245, 79;  -- correct (C)
EXEC AddStudentAnswer 87, 2, 246, 82;  -- wrong (B)
EXEC AddStudentAnswer 87, 2, 248, 92;  -- wrong (D)
EXEC AddStudentAnswer 87, 2, 255, 110; -- wrong (B)
EXEC AddStudentAnswer 87, 2, 253, 105; -- correct (A)
EXEC AddStudentAnswer 87, 2, 251, 102; -- wrong (B)


-- StudentExamID 10 → Student 88, Exam 3
EXEC AddStudentAnswer 88, 3, 269, 152;  -- correct (B)
EXEC AddStudentAnswer 88, 3, 263, 127;  -- correct (A)
EXEC AddStudentAnswer 88, 3, 265, 136;  -- wrong (B)
EXEC AddStudentAnswer 88, 3, 266, 141;  -- wrong (C)
EXEC AddStudentAnswer 88, 3, 270, 156;  -- correct (B)
EXEC AddStudentAnswer 88, 3, 274, 166;  -- wrong (B)
EXEC AddStudentAnswer 88, 3, 276, 169;  -- correct (A)
EXEC AddStudentAnswer 88, 3, 280, 177;  -- correct (A)
EXEC AddStudentAnswer 88, 3, 273, 163;  -- wrong (A)
EXEC AddStudentAnswer 88, 3, 272, 162;  -- correct (B)

-- StudentExamID 11 → Student 89, Exam 3
EXEC AddStudentAnswer 89, 3, 269, 154;  -- wrong (D)
EXEC AddStudentAnswer 89, 3, 263, 128;  -- wrong (B)
EXEC AddStudentAnswer 89, 3, 265, 135;  -- correct (A)
EXEC AddStudentAnswer 89, 3, 266, 140;  -- correct (B)
EXEC AddStudentAnswer 89, 3, 270, 157;  -- wrong (C)
EXEC AddStudentAnswer 89, 3, 274, 165;  -- correct (A)
EXEC AddStudentAnswer 89, 3, 276, 170;  -- wrong (B)
EXEC AddStudentAnswer 89, 3, 280, 178;  -- wrong (B)
EXEC AddStudentAnswer 89, 3, 273, 164;  -- correct (B)
EXEC AddStudentAnswer 89, 3, 272, 161;  -- wrong (A)

-- StudentExamID 12 → Student 90, Exam 3
EXEC AddStudentAnswer 90, 3, 269, 153;  -- wrong (C)
EXEC AddStudentAnswer 90, 3, 263, 129;  -- wrong (C)
EXEC AddStudentAnswer 90, 3, 265, 138;  -- wrong (D)
EXEC AddStudentAnswer 90, 3, 266, 140;  -- correct (B)
EXEC AddStudentAnswer 90, 3, 270, 156;  -- correct (B)
EXEC AddStudentAnswer 90, 3, 274, 166;  -- wrong (B)
EXEC AddStudentAnswer 90, 3, 276, 169;  -- correct (A)
EXEC AddStudentAnswer 90, 3, 280, 177;  -- correct (A)
EXEC AddStudentAnswer 90, 3, 273, 163;  -- wrong (A)
EXEC AddStudentAnswer 90, 3, 272, 162;  -- correct (B)

-- StudentExamID 13 → Student 91, Exam 3
EXEC AddStudentAnswer 91, 3, 269, 152;  -- correct (B)
EXEC AddStudentAnswer 91, 3, 263, 130;  -- wrong (D)
EXEC AddStudentAnswer 91, 3, 265, 137;  -- wrong (C)
EXEC AddStudentAnswer 91, 3, 266, 139;  -- wrong (A)
EXEC AddStudentAnswer 91, 3, 270, 158;  -- wrong (D)
EXEC AddStudentAnswer 91, 3, 274, 165;  -- correct (A)
EXEC AddStudentAnswer 91, 3, 276, 170;  -- wrong (B)
EXEC AddStudentAnswer 91, 3, 280, 178;  -- wrong (B)
EXEC AddStudentAnswer 91, 3, 273, 164;  -- correct (B)
EXEC AddStudentAnswer 91, 3, 272, 161;  -- wrong (A)



-- StudentExamID 14 → Student 92, Exam 4
EXEC AddStudentAnswer 92, 4, 282, 183;  -- correct (A)
EXEC AddStudentAnswer 92, 4, 284, 188;  -- wrong (B)
EXEC AddStudentAnswer 92, 4, 289, 207;  -- correct (A)
EXEC AddStudentAnswer 92, 4, 285, 192;  -- wrong (B)
EXEC AddStudentAnswer 92, 4, 300, 233;  -- correct (A)
EXEC AddStudentAnswer 92, 4, 298, 230;  -- correct (B)
EXEC AddStudentAnswer 92, 4, 294, 221;  -- correct (A)
EXEC AddStudentAnswer 92, 4, 291, 215;  -- correct (A)
EXEC AddStudentAnswer 92, 4, 296, 226;  -- wrong (B)
EXEC AddStudentAnswer 92, 4, 299, 231;  -- correct (A)

-- StudentExamID 15 → Student 93, Exam 4
EXEC AddStudentAnswer 93, 4, 282, 184;  -- wrong (B)
EXEC AddStudentAnswer 93, 4, 284, 187;  -- correct (A)
EXEC AddStudentAnswer 93, 4, 289, 208;  -- wrong (B)
EXEC AddStudentAnswer 93, 4, 285, 191;  -- correct (A)
EXEC AddStudentAnswer 93, 4, 300, 234;  -- wrong (B)
EXEC AddStudentAnswer 93, 4, 298, 229;  -- wrong (A)
EXEC AddStudentAnswer 93, 4, 294, 222;  -- wrong (B)
EXEC AddStudentAnswer 93, 4, 291, 216;  -- wrong (B)
EXEC AddStudentAnswer 93, 4, 296, 225;  -- correct (A)
EXEC AddStudentAnswer 93, 4, 299, 232;  -- wrong (B)

-- StudentExamID 16 → Student 94, Exam 4
EXEC AddStudentAnswer 94, 4, 282, 185;  -- wrong (C)
EXEC AddStudentAnswer 94, 4, 284, 189;  -- wrong (C)
EXEC AddStudentAnswer 94, 4, 289, 209;  -- wrong (C)
EXEC AddStudentAnswer 94, 4, 285, 193;  -- wrong (C)
EXEC AddStudentAnswer 94, 4, 300, 233;  -- correct (A)
EXEC AddStudentAnswer 94, 4, 298, 230;  -- correct (B)
EXEC AddStudentAnswer 94, 4, 294, 221;  -- correct (A)
EXEC AddStudentAnswer 94, 4, 291, 215;  -- correct (A)
EXEC AddStudentAnswer 94, 4, 296, 225;  -- correct (A)
EXEC AddStudentAnswer 94, 4, 299, 231;  -- correct (A)

-- StudentExamID 17 → Student 95, Exam 4
EXEC AddStudentAnswer 95, 4, 282, 186;  -- wrong (D)
EXEC AddStudentAnswer 95, 4, 284, 190;  -- wrong (D)
EXEC AddStudentAnswer 95, 4, 289, 210;  -- wrong (D)
EXEC AddStudentAnswer 95, 4, 285, 194;  -- wrong (D)
EXEC AddStudentAnswer 95, 4, 300, 234;  -- wrong (B)
EXEC AddStudentAnswer 95, 4, 298, 229;  -- wrong (A)
EXEC AddStudentAnswer 95, 4, 294, 222;  -- wrong (B)
EXEC AddStudentAnswer 95, 4, 291, 216;  -- wrong (B)
EXEC AddStudentAnswer 95, 4, 296, 226;  -- wrong (B)
EXEC AddStudentAnswer 95, 4, 299, 232;  -- wrong (B)


-- StudentExamID 18 → Student 96, Exam 5
EXEC AddStudentAnswer 96, 5, 306, 259;  -- correct (A)
EXEC AddStudentAnswer 96, 5, 301, 240;  -- wrong (B)
EXEC AddStudentAnswer 96, 5, 308, 268;  -- wrong (B)
EXEC AddStudentAnswer 96, 5, 319, 295;  -- correct (A)
EXEC AddStudentAnswer 96, 5, 311, 280;  -- wrong (B)
EXEC AddStudentAnswer 96, 5, 313, 283;  -- correct (A)
EXEC AddStudentAnswer 96, 5, 312, 281;  -- correct (A)
EXEC AddStudentAnswer 96, 5, 314, 286;  -- wrong (B)
EXEC AddStudentAnswer 96, 5, 317, 291;  -- correct (A)
EXEC AddStudentAnswer 96, 5, 315, 288;  -- wrong (B)

-- StudentExamID 19 → Student 97, Exam 5
EXEC AddStudentAnswer 97, 5, 306, 260;  -- wrong (B)
EXEC AddStudentAnswer 97, 5, 301, 239;  -- correct (A)
EXEC AddStudentAnswer 97, 5, 308, 267;  -- correct (A)
EXEC AddStudentAnswer 97, 5, 319, 296;  -- wrong (B)
EXEC AddStudentAnswer 97, 5, 311, 279;  -- correct (A)
EXEC AddStudentAnswer 97, 5, 313, 284;  -- wrong (B)
EXEC AddStudentAnswer 97, 5, 312, 282;  -- wrong (B)
EXEC AddStudentAnswer 97, 5, 314, 285;  -- correct (A)
EXEC AddStudentAnswer 97, 5, 317, 292;  -- wrong (B)
EXEC AddStudentAnswer 97, 5, 315, 287;  -- correct (A)

-- StudentExamID 20 → Student 98, Exam 5
EXEC AddStudentAnswer 98, 5, 306, 261;  -- wrong (C)
EXEC AddStudentAnswer 98, 5, 301, 242;  -- wrong (D)
EXEC AddStudentAnswer 98, 5, 308, 267;  -- correct (A)
EXEC AddStudentAnswer 98, 5, 319, 295;  -- correct (A)
EXEC AddStudentAnswer 98, 5, 311, 280;  -- wrong (B)
EXEC AddStudentAnswer 98, 5, 313, 284;  -- wrong (B)
EXEC AddStudentAnswer 98, 5, 312, 281;  -- correct (A)
EXEC AddStudentAnswer 98, 5, 314, 286;  -- wrong (B)
EXEC AddStudentAnswer 98, 5, 317, 291;  -- correct (A)
EXEC AddStudentAnswer 98, 5, 315, 288;  -- wrong (B)

-- StudentExamID 21 → Student 99, Exam 5
EXEC AddStudentAnswer 99, 5, 306, 262;  -- wrong (D)
EXEC AddStudentAnswer 99, 5, 301, 239;  -- correct (A)
EXEC AddStudentAnswer 99, 5, 308, 270;  -- wrong (D)
EXEC AddStudentAnswer 99, 5, 319, 296;  -- wrong (B)
EXEC AddStudentAnswer 99, 5, 311, 279;  -- correct (A)
EXEC AddStudentAnswer 99, 5, 313, 283;  -- correct (A)
EXEC AddStudentAnswer 99, 5, 312, 282;  -- wrong (B)
EXEC AddStudentAnswer 99, 5, 314, 285;  -- correct (A)
EXEC AddStudentAnswer 99, 5, 317, 292;  -- wrong (B)
EXEC AddStudentAnswer 99, 5, 315, 287;  -- correct (A)


----- Extra Exams For Student 21 to test the second report 

-- StudentExamID 22 → Student 21, Exam 2
EXEC AddStudentAnswer 21, 2, 242, 66;  -- correct (B)
EXEC AddStudentAnswer 21, 2, 247, 86;  -- correct (B)
EXEC AddStudentAnswer 21, 2, 249, 96;  -- correct (D)
EXEC AddStudentAnswer 21, 2, 241, 62;  -- wrong (B)
EXEC AddStudentAnswer 21, 2, 245, 79;  -- correct (C)
EXEC AddStudentAnswer 21, 2, 246, 83;  -- wrong (C)
EXEC AddStudentAnswer 21, 2, 248, 91;  -- correct (C)
EXEC AddStudentAnswer 21, 2, 255, 109; -- correct (A)
EXEC AddStudentAnswer 21, 2, 253, 106; -- wrong (B)
EXEC AddStudentAnswer 21, 2, 251, 101; -- correct (A)

-- StudentExamID 23 → Student 21, Exam 3
EXEC AddStudentAnswer 21, 3, 269, 152;  -- correct (B)
EXEC AddStudentAnswer 21, 3, 263, 127;  -- correct (A)
EXEC AddStudentAnswer 21, 3, 265, 136;  -- wrong (B)
EXEC AddStudentAnswer 21, 3, 266, 141;  -- wrong (C)
EXEC AddStudentAnswer 21, 3, 270, 156;  -- correct (B)
EXEC AddStudentAnswer 21, 3, 274, 166;  -- wrong (B)
EXEC AddStudentAnswer 21, 3, 276, 169;  -- correct (A)
EXEC AddStudentAnswer 21, 3, 280, 177;  -- correct (A)
EXEC AddStudentAnswer 21, 3, 273, 163;  -- wrong (A)
EXEC AddStudentAnswer 21, 3, 272, 162;  -- correct (B)



--////////////////////////////////////////////////////////////////// Exam Generation (already done above and executed)

-- Exam 6: DevOps
/*EXEC Generate_Exam
    @CourseName = 'DevOps',
    @ExamDate = '2026-01-06',
    @StartTime = '09:00',
    @EndTime = '11:00',
    @TotalMCQQuestions = 7,
    @TotalTrueFalseQuestions = 3;*/


--////////////////////////////////////////////////////////////////// Exam Correction (StudenID , ExamID)


EXEC Student_Exam_Correction 21, 1;
EXEC Student_Exam_Correction 21, 2;
EXEC Student_Exam_Correction 21, 3;

EXEC Student_Exam_Correction 33, 2;

EXEC Student_Exam_Correction 88, 3;

--//////////////////////////////////////////////////////////////// Exam Correct Answers (model answer) (ExamID)

EXEC Get_Exam_Correct_Answers 1;


--/////////////////////////////////////////////////////////////// Exam Student Answers (StudenID , ExamID)

EXEC Student_Exam_Answers 21, 1;

--////////////////////////////////////////////////////////////// Exam Student Answers with correct choices (StudenID , ExamID)

EXEC Student_Exam_Answers_with_Correct_Choices 21, 1;




--/////////////////////////////////////////////////////////////// The 6 Required Reports 


--1. Report that returns the students information according to Department No parameter. (TrackID)

EXEC GetStudentByTrack 1;


--2. Report that takes the student ID and returns the grades of the student in all courses they had an exam on. (StudentID)

EXEC StudentGradesReport 21;


--3. Report that takes the instructor ID and returns the name of the courses that he teaches and the number of student per course. (InstructorID)

EXEC GetCoursesAndStudentsByInstID 2;


--4. Report that takes course ID and returns its topics. (CourseID)

EXEC GetTopicsByCourseId 3;


--5. Report that takes exam number and returns the Questions in it and choices. (ExamID)

EXEC GetExamQuestionsWithChoicesReport 1;


--6. Report that takes exam number and the student ID then returns the Questions in this exam with the student answers. (StudentID , ExamID)

EXEC Student_Exam_Answers 21, 1; -- option 1 : Exam Student Answers without correct choices.

EXEC Student_Exam_Answers_with_Correct_Choices 21, 1; -- option 2 :Exam Student Answers with correct choices.




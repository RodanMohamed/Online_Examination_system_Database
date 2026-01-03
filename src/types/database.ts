export interface Branch {
  BranchID: number
  BranchName: string
  BranchLocation: string
  created_at?: string
}

export interface Instructor {
  InstructorID: number
  FirstName: string
  LastName: string
  Email: string
  Phone?: string
  HireDate?: string
  user_id?: string
  created_at?: string
}

export interface Track {
  TrackID: number
  TrackName: string
  TrackSupervisor?: number
  created_at?: string
}

export interface Course {
  CourseID: number
  CourseName: string
  CourseDescription?: string
  created_at?: string
}

export interface Student {
  StudentID: number
  FirstName: string
  LastName: string
  Email: string
  Phone?: string
  EnrollmentDate?: string
  TrackID?: number
  user_id?: string
  created_at?: string
}

export interface Topic {
  TopicID: number
  TopicName: string
  TopicDescription?: string
  created_at?: string
}

export interface Question {
  QuestionID: number
  QuestionText: string
  QuestionType: 'M' | 'T'
  QuestionMark: number
  CourseID: number
  created_at?: string
}

export interface Choice {
  ChoiceID: number
  QuestionID: number
  ChoiceLabel: string
  ChoiceText: string
  IsCorrectChoice: boolean
  created_at?: string
}

export interface Exam {
  ExamID: number
  ExamDate: string
  StartTime: string
  EndTime: string
  TotalMCQQuestions: number
  TotalTrueFalseQuestions: number
  TotalGrade: number
  created_at?: string
}

export interface StudentExam {
  StudentExamID: number
  StudentID: number
  ExamID: number
  StartTime: string
  EndTime: string
  TotalScore?: number
  Percentage?: number
  created_at?: string
}

export interface StudentAnswer {
  StudentAnswerID: number
  StudentExamID: number
  QuestionID: number
  AnswerID?: number
  IsCorrect?: boolean
  Mark?: number
  created_at?: string
}

export type UserRole = 'admin' | 'instructor' | 'student'

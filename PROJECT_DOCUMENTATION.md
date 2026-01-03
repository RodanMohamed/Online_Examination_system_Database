# Examination System - Web Application

A comprehensive online examination system built with React, TypeScript, and Supabase.

## Features

### Admin Dashboard
- **Manage Branches**: Create and manage educational branches
- **Manage Tracks**: Create and manage educational tracks/departments
- **Manage Instructors**: Add and assign instructors to tracks and courses
- **Manage Students**: Register and manage student information
- **Manage Courses**: Create courses and assign them to tracks
- **Manage Questions**: Create MCQ and True/False questions with multiple choices
- **Generate Exams**: Create exams by selecting questions from courses

### Student Portal
- **Take Exams**: Students can take assigned exams with a user-friendly interface
- **Real-time Saving**: Answers are saved automatically as students select them
- **View Results**: Students can view their exam results, scores, and percentages
- **Performance Overview**: Dashboard showing overall performance and grades

### Instructor Portal
- **View Courses**: See all assigned courses
- **Manage Questions**: Create and manage exam questions for their courses
- **View Reports**: Access student performance reports

### Reports System
The system includes 6 comprehensive reports:

1. **Students by Track**: Get all students in a specific track
2. **Student Grades**: View all exam results for a specific student
3. **Instructor Courses**: See courses taught by an instructor and student count
4. **Course Topics**: View all topics covered in a course
5. **Exam Questions**: Display all questions and choices in an exam
6. **Student Exam Answers**: View a student's answers for a specific exam

## Database Schema

### Main Entities
- **Branch**: Educational branches and locations
- **Track**: Educational tracks/departments with supervisors
- **Instructor**: Teaching staff with authentication
- **Course**: Academic courses with descriptions
- **Student**: Enrolled students with track assignments
- **Topic**: Course topics
- **Question**: Exam questions (MCQ or True/False)
- **Choice**: Answer choices for questions
- **Exam**: Examinations with timing and grading

### Relationship Tables
- **Branch_Track**: Branches offering tracks
- **Track_Instructor**: Instructors assigned to tracks
- **Track_Course**: Courses in tracks
- **Instructor_Course**: Instructors teaching courses
- **Course_Topic**: Topics in courses
- **Exam_Question**: Questions in exams
- **Student_Exam**: Students taking exams with scores
- **Student_Answer**: Student answers with correctness and marks

## Technology Stack

- **Frontend**: React 18 with TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Routing**: React Router v6

## Key Features Implementation

### Authentication & Authorization
- Role-based access control (Admin, Instructor, Student)
- Each role has specific permissions and views
- Users are linked to their respective entities (Instructor/Student tables)

### Exam System
- **Exam Generation**: Admins can generate exams with specific numbers of MCQ and T/F questions
- **Auto-scoring**: Answers are automatically checked against correct choices
- **Real-time Updates**: Student progress is saved immediately
- **Results Calculation**: Total scores and percentages calculated automatically

### Security
- Row Level Security (RLS) enabled on all tables
- Students can only view/edit their own data
- Instructors can view their assigned courses
- Admins have full access to manage the system

## Sample Data

The database is pre-populated with:
- 3 Branches (Main Campus, Alexandria, Giza)
- 3 Tracks (Computer Science, IT, Software Engineering)
- 3 Instructors
- 5 Courses (C#, ASP.NET, SQL Server, JavaScript, HTML & CSS)
- 4 Topics
- 4 Students

## Getting Started

### Prerequisites
- Node.js 18+
- Supabase account (already configured)

### Installation
```bash
npm install
```

### Development
```bash
npm run dev
```

### Build
```bash
npm run build
```

### Preview Production Build
```bash
npm run preview
```

## Environment Variables

The following environment variables are configured in `.env`:
- `VITE_SUPABASE_URL`: Your Supabase project URL
- `VITE_SUPABASE_ANON_KEY`: Your Supabase anonymous key

## Project Structure

```
src/
├── components/         # Reusable components
│   └── Layout.tsx     # Main layout with navigation
├── contexts/          # React contexts
│   └── AuthContext.tsx # Authentication state management
├── lib/               # Utility functions
│   └── supabase.ts    # Supabase client configuration
├── pages/             # Page components
│   ├── admin/         # Admin pages
│   │   ├── Students.tsx
│   │   ├── Courses.tsx
│   │   └── Questions.tsx
│   ├── student/       # Student pages
│   │   ├── Exams.tsx
│   │   ├── TakeExam.tsx
│   │   └── Results.tsx
│   ├── Dashboard.tsx  # Role-based dashboard
│   ├── Login.tsx      # Authentication page
│   └── Reports.tsx    # Reports section
├── types/             # TypeScript type definitions
│   └── database.ts    # Database entity types
├── App.tsx            # Main app component with routing
├── main.tsx           # Application entry point
└── index.css          # Global styles

## User Roles & Permissions

### Admin
- Full CRUD access to all entities
- Can manage branches, tracks, instructors, students, courses
- Can create questions and generate exams
- Access to all reports

### Instructor
- View assigned courses
- Create and manage questions for their courses
- View student performance reports
- Cannot modify student data or create exams

### Student
- Take assigned exams
- View their own exam results
- View performance dashboard
- Cannot access other students' data

## Database Functions

The original stored procedures have been adapted to work with Supabase:
- Exam generation logic
- Auto-correction system
- Answer validation
- Report generation

## Design Philosophy

- **Clean & Modern UI**: Professional interface with clear visual hierarchy
- **Responsive Design**: Works on all device sizes
- **User-Friendly**: Intuitive navigation and clear feedback
- **Performance**: Optimized queries and efficient state management
- **Security**: Comprehensive RLS policies and authentication
- **Maintainability**: Well-organized code structure with TypeScript

## Future Enhancements

Potential features for future versions:
- Email notifications for exam schedules
- PDF export for reports
- Question bank management
- Exam templates
- Analytics dashboard
- Bulk data import/export
- Advanced filtering and search
```

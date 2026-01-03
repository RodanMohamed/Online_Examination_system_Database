import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider, useAuth } from './contexts/AuthContext'
import Layout from './components/Layout'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import Branches from './pages/admin/Branches'
import Tracks from './pages/admin/Tracks'
import Instructors from './pages/admin/Instructors'
import Students from './pages/admin/Students'
import Courses from './pages/admin/Courses'
import Questions from './pages/admin/Questions'
import Exams from './pages/admin/Exams'
import StudentExams from './pages/student/Exams'
import TakeExam from './pages/student/TakeExam'
import StudentResults from './pages/student/Results'
import Reports from './pages/Reports'

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth()

  if (loading) {
    return <div className="min-h-screen flex items-center justify-center">Loading...</div>
  }

  if (!user) {
    return <Navigate to="/login" replace />
  }

  return <Layout>{children}</Layout>
}

function AppRoutes() {
  const { user, loading } = useAuth()

  if (loading) {
    return <div className="min-h-screen flex items-center justify-center">Loading...</div>
  }

  return (
    <Routes>
      <Route path="/login" element={user ? <Navigate to="/" replace /> : <Login />} />

      <Route path="/" element={
        <ProtectedRoute>
          <Dashboard />
        </ProtectedRoute>
      } />

      <Route path="/admin/branches" element={
        <ProtectedRoute>
          <Branches />
        </ProtectedRoute>
      } />

      <Route path="/admin/tracks" element={
        <ProtectedRoute>
          <Tracks />
        </ProtectedRoute>
      } />

      <Route path="/admin/instructors" element={
        <ProtectedRoute>
          <Instructors />
        </ProtectedRoute>
      } />

      <Route path="/admin/students" element={
        <ProtectedRoute>
          <Students />
        </ProtectedRoute>
      } />

      <Route path="/admin/courses" element={
        <ProtectedRoute>
          <Courses />
        </ProtectedRoute>
      } />

      <Route path="/admin/questions" element={
        <ProtectedRoute>
          <Questions />
        </ProtectedRoute>
      } />

      <Route path="/admin/exams" element={
        <ProtectedRoute>
          <Exams />
        </ProtectedRoute>
      } />

      <Route path="/student/exams" element={
        <ProtectedRoute>
          <StudentExams />
        </ProtectedRoute>
      } />

      <Route path="/student/exam/:examId" element={
        <ProtectedRoute>
          <TakeExam />
        </ProtectedRoute>
      } />

      <Route path="/student/results" element={
        <ProtectedRoute>
          <StudentResults />
        </ProtectedRoute>
      } />

      <Route path="/reports" element={
        <ProtectedRoute>
          <Reports />
        </ProtectedRoute>
      } />

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </BrowserRouter>
  )
}

import { ReactNode } from 'react'
import { useAuth } from '../contexts/AuthContext'
import { LogOut, Home, FileText, Users, BookOpen, GraduationCap, ClipboardList } from 'lucide-react'
import { Link, useNavigate } from 'react-router-dom'

interface LayoutProps {
  children: ReactNode
}

export default function Layout({ children }: LayoutProps) {
  const { user, userRole, signOut } = useAuth()
  const navigate = useNavigate()

  const handleSignOut = async () => {
    try {
      await signOut()
      navigate('/login')
    } catch (error) {
      console.error('Error signing out:', error)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <GraduationCap className="h-8 w-8 text-blue-600" />
              <span className="ml-2 text-xl font-bold text-gray-900">Examination System</span>
            </div>

            {user && (
              <div className="flex items-center space-x-4">
                <Link to="/" className="flex items-center text-gray-700 hover:text-blue-600 transition-colors">
                  <Home className="h-5 w-5 mr-1" />
                  <span>Home</span>
                </Link>

                {userRole === 'admin' && (
                  <>
                    <Link to="/admin/students" className="flex items-center text-gray-700 hover:text-blue-600 transition-colors">
                      <Users className="h-5 w-5 mr-1" />
                      <span>Students</span>
                    </Link>
                    <Link to="/admin/courses" className="flex items-center text-gray-700 hover:text-blue-600 transition-colors">
                      <BookOpen className="h-5 w-5 mr-1" />
                      <span>Courses</span>
                    </Link>
                  </>
                )}

                {userRole === 'student' && (
                  <>
                    <Link to="/student/exams" className="flex items-center text-gray-700 hover:text-blue-600 transition-colors">
                      <ClipboardList className="h-5 w-5 mr-1" />
                      <span>My Exams</span>
                    </Link>
                    <Link to="/student/results" className="flex items-center text-gray-700 hover:text-blue-600 transition-colors">
                      <FileText className="h-5 w-5 mr-1" />
                      <span>Results</span>
                    </Link>
                  </>
                )}

                {userRole === 'instructor' && (
                  <>
                    <Link to="/instructor/courses" className="flex items-center text-gray-700 hover:text-blue-600 transition-colors">
                      <BookOpen className="h-5 w-5 mr-1" />
                      <span>My Courses</span>
                    </Link>
                    <Link to="/instructor/questions" className="flex items-center text-gray-700 hover:text-blue-600 transition-colors">
                      <ClipboardList className="h-5 w-5 mr-1" />
                      <span>Questions</span>
                    </Link>
                  </>
                )}

                <Link to="/reports" className="flex items-center text-gray-700 hover:text-blue-600 transition-colors">
                  <FileText className="h-5 w-5 mr-1" />
                  <span>Reports</span>
                </Link>

                <span className="text-sm text-gray-600 border-l pl-4">
                  {user.email} ({userRole})
                </span>

                <button
                  onClick={handleSignOut}
                  className="flex items-center text-gray-700 hover:text-red-600 transition-colors"
                >
                  <LogOut className="h-5 w-5 mr-1" />
                  <span>Sign Out</span>
                </button>
              </div>
            )}
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {children}
      </main>
    </div>
  )
}

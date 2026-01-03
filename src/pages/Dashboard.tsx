import { useAuth } from '../contexts/AuthContext'
import { Users, BookOpen, ClipboardList, BarChart3, GraduationCap, FileText } from 'lucide-react'
import { Link } from 'react-router-dom'

export default function Dashboard() {
  const { userRole } = useAuth()

  if (userRole === 'admin') {
    return (
      <div>
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Admin Dashboard</h1>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <Link to="/admin/branches" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow border-l-4 border-blue-600">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-semibold text-gray-900">Branches</h3>
              <GraduationCap className="h-8 w-8 text-blue-600" />
            </div>
            <p className="text-gray-600">Manage educational branches and locations</p>
          </Link>

          <Link to="/admin/tracks" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow border-l-4 border-green-600">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-semibold text-gray-900">Tracks</h3>
              <BarChart3 className="h-8 w-8 text-green-600" />
            </div>
            <p className="text-gray-600">Manage educational tracks and departments</p>
          </Link>

          <Link to="/admin/instructors" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow border-l-4 border-purple-600">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-semibold text-gray-900">Instructors</h3>
              <Users className="h-8 w-8 text-purple-600" />
            </div>
            <p className="text-gray-600">Manage teaching staff and assignments</p>
          </Link>

          <Link to="/admin/students" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow border-l-4 border-orange-600">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-semibold text-gray-900">Students</h3>
              <Users className="h-8 w-8 text-orange-600" />
            </div>
            <p className="text-gray-600">Manage enrolled students</p>
          </Link>

          <Link to="/admin/courses" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow border-l-4 border-red-600">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-semibold text-gray-900">Courses</h3>
              <BookOpen className="h-8 w-8 text-red-600" />
            </div>
            <p className="text-gray-600">Manage courses and curriculum</p>
          </Link>

          <Link to="/admin/questions" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow border-l-4 border-teal-600">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-semibold text-gray-900">Questions</h3>
              <ClipboardList className="h-8 w-8 text-teal-600" />
            </div>
            <p className="text-gray-600">Manage exam questions and choices</p>
          </Link>

          <Link to="/admin/exams" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow border-l-4 border-pink-600">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-semibold text-gray-900">Exams</h3>
              <FileText className="h-8 w-8 text-pink-600" />
            </div>
            <p className="text-gray-600">Generate and manage exams</p>
          </Link>

          <Link to="/reports" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow border-l-4 border-indigo-600">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-semibold text-gray-900">Reports</h3>
              <BarChart3 className="h-8 w-8 text-indigo-600" />
            </div>
            <p className="text-gray-600">View system reports and analytics</p>
          </Link>
        </div>
      </div>
    )
  }

  if (userRole === 'student') {
    return (
      <div>
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Student Dashboard</h1>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Link to="/student/exams" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow border-l-4 border-blue-600">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-semibold text-gray-900">My Exams</h3>
              <ClipboardList className="h-8 w-8 text-blue-600" />
            </div>
            <p className="text-gray-600">Take available exams and view scheduled exams</p>
          </Link>

          <Link to="/student/results" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow border-l-4 border-green-600">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-semibold text-gray-900">My Results</h3>
              <FileText className="h-8 w-8 text-green-600" />
            </div>
            <p className="text-gray-600">View your exam results and grades</p>
          </Link>
        </div>
      </div>
    )
  }

  if (userRole === 'instructor') {
    return (
      <div>
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Instructor Dashboard</h1>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <Link to="/instructor/courses" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow border-l-4 border-blue-600">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-semibold text-gray-900">My Courses</h3>
              <BookOpen className="h-8 w-8 text-blue-600" />
            </div>
            <p className="text-gray-600">View your assigned courses</p>
          </Link>

          <Link to="/instructor/questions" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow border-l-4 border-green-600">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-semibold text-gray-900">Questions</h3>
              <ClipboardList className="h-8 w-8 text-green-600" />
            </div>
            <p className="text-gray-600">Create and manage exam questions</p>
          </Link>

          <Link to="/reports" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow border-l-4 border-purple-600">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-semibold text-gray-900">Reports</h3>
              <BarChart3 className="h-8 w-8 text-purple-600" />
            </div>
            <p className="text-gray-600">View student performance reports</p>
          </Link>
        </div>
      </div>
    )
  }

  return null
}

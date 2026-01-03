import { useState, useEffect } from 'react'
import { supabase } from '../../lib/supabase'
import { useAuth } from '../../contexts/AuthContext'
import { Link } from 'react-router-dom'
import { Calendar, Clock, BookOpen } from 'lucide-react'

export default function StudentExams() {
  const { userId } = useAuth()
  const [exams, setExams] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (userId) {
      fetchStudentExams()
    }
  }, [userId])

  const fetchStudentExams = async () => {
    try {
      const { data, error } = await supabase
        .from('Student_Exam')
        .select(`
          *,
          Exam (
            ExamID,
            ExamDate,
            StartTime,
            EndTime,
            TotalGrade,
            TotalMCQQuestions,
            TotalTrueFalseQuestions
          )
        `)
        .eq('StudentID', userId)
        .order('created_at', { ascending: false })

      if (error) throw error
      setExams(data || [])
    } catch (error) {
      console.error('Error fetching exams:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) return <div>Loading...</div>

  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-8">My Exams</h1>

      {exams.length === 0 ? (
        <div className="bg-white p-8 rounded-lg shadow-md text-center">
          <BookOpen className="h-16 w-16 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-600 text-lg">No exams assigned yet</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {exams.map((studentExam) => (
            <div
              key={studentExam.StudentExamID}
              className="bg-white p-6 rounded-lg shadow-md border-l-4 border-blue-600"
            >
              <div className="flex justify-between items-start mb-4">
                <h3 className="text-xl font-semibold text-gray-900">
                  Exam #{studentExam.Exam.ExamID}
                </h3>
                {studentExam.TotalScore !== null ? (
                  <span className="px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm font-semibold">
                    Completed
                  </span>
                ) : (
                  <span className="px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-sm font-semibold">
                    Pending
                  </span>
                )}
              </div>

              <div className="space-y-2 mb-4">
                <div className="flex items-center text-gray-600">
                  <Calendar className="h-4 w-4 mr-2" />
                  <span>{new Date(studentExam.Exam.ExamDate).toLocaleDateString()}</span>
                </div>
                <div className="flex items-center text-gray-600">
                  <Clock className="h-4 w-4 mr-2" />
                  <span>
                    {studentExam.Exam.StartTime} - {studentExam.Exam.EndTime}
                  </span>
                </div>
                <div className="text-gray-600">
                  <span className="font-semibold">Questions:</span> {studentExam.Exam.TotalMCQQuestions} MCQ, {studentExam.Exam.TotalTrueFalseQuestions} T/F
                </div>
                <div className="text-gray-600">
                  <span className="font-semibold">Total Grade:</span> {studentExam.Exam.TotalGrade}
                </div>
              </div>

              {studentExam.TotalScore !== null ? (
                <div className="bg-green-50 p-3 rounded-lg">
                  <div className="text-sm text-gray-600">Your Score</div>
                  <div className="text-2xl font-bold text-green-600">
                    {studentExam.TotalScore} / {studentExam.Exam.TotalGrade}
                  </div>
                  <div className="text-sm text-gray-600">
                    {studentExam.Percentage?.toFixed(2)}%
                  </div>
                </div>
              ) : (
                <Link
                  to={`/student/exam/${studentExam.Exam.ExamID}`}
                  className="block w-full bg-blue-600 text-white text-center py-2 rounded-lg hover:bg-blue-700 transition-colors font-semibold"
                >
                  Take Exam
                </Link>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

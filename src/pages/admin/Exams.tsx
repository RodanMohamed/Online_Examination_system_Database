import { useState, useEffect } from 'react'
import { supabase } from '../../lib/supabase'
import { Exam } from '../../types/database'
import { Trash2, Calendar, Clock } from 'lucide-react'

export default function Exams() {
  const [exams, setExams] = useState<Exam[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchExams()
  }, [])

  const fetchExams = async () => {
    try {
      const { data, error } = await supabase
        .from('Exam')
        .select('*')
        .order('ExamID', { ascending: false })

      if (error) throw error
      setExams(data || [])
    } catch (error) {
      console.error('Error fetching exams:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Are you sure you want to delete this exam?')) return

    try {
      const { error } = await supabase
        .from('Exam')
        .delete()
        .eq('ExamID', id)

      if (error) throw error
      fetchExams()
    } catch (error) {
      console.error('Error deleting exam:', error)
      alert('Error deleting exam')
    }
  }

  if (loading) return <div>Loading...</div>

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Exams</h1>
        <div className="bg-blue-50 border border-blue-200 text-blue-700 px-4 py-2 rounded-lg">
          <p className="text-sm">Use the stored procedures to generate exams with questions from courses</p>
        </div>
      </div>

      {exams.length === 0 ? (
        <div className="bg-white p-8 rounded-lg shadow-md text-center">
          <Calendar className="h-16 w-16 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-600 text-lg">No exams created yet</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {exams.map((exam) => (
            <div key={exam.ExamID} className="bg-white p-6 rounded-lg shadow-md border-l-4 border-blue-600">
              <div className="flex justify-between items-start mb-4">
                <h3 className="text-xl font-semibold text-gray-900">Exam #{exam.ExamID}</h3>
                <button
                  onClick={() => handleDelete(exam.ExamID)}
                  className="text-red-600 hover:text-red-900"
                >
                  <Trash2 className="h-5 w-5" />
                </button>
              </div>

              <div className="space-y-3">
                <div className="flex items-center text-gray-600">
                  <Calendar className="h-4 w-4 mr-2" />
                  <span>{new Date(exam.ExamDate).toLocaleDateString()}</span>
                </div>
                <div className="flex items-center text-gray-600">
                  <Clock className="h-4 w-4 mr-2" />
                  <span>{exam.StartTime} - {exam.EndTime}</span>
                </div>

                <div className="border-t pt-3 mt-3">
                  <div className="grid grid-cols-2 gap-2 text-sm">
                    <div className="bg-blue-50 p-2 rounded">
                      <div className="text-gray-600">MCQ</div>
                      <div className="font-semibold text-blue-600">{exam.TotalMCQQuestions}</div>
                    </div>
                    <div className="bg-green-50 p-2 rounded">
                      <div className="text-gray-600">T/F</div>
                      <div className="font-semibold text-green-600">{exam.TotalTrueFalseQuestions}</div>
                    </div>
                  </div>
                  <div className="mt-2 bg-gray-50 p-2 rounded">
                    <div className="text-gray-600 text-sm">Total Grade</div>
                    <div className="font-bold text-gray-900 text-lg">{exam.TotalGrade}</div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

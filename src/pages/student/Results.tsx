import { useState, useEffect } from 'react'
import { supabase } from '../../lib/supabase'
import { useAuth } from '../../contexts/AuthContext'
import { Award, TrendingUp } from 'lucide-react'

export default function StudentResults() {
  const { userId } = useAuth()
  const [results, setResults] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (userId) {
      fetchResults()
    }
  }, [userId])

  const fetchResults = async () => {
    try {
      const { data, error } = await supabase
        .from('Student_Exam')
        .select(`
          *,
          Exam (
            ExamID,
            ExamDate,
            TotalGrade
          )
        `)
        .eq('StudentID', userId)
        .not('TotalScore', 'is', null)
        .order('created_at', { ascending: false })

      if (error) throw error
      setResults(data || [])
    } catch (error) {
      console.error('Error fetching results:', error)
    } finally {
      setLoading(false)
    }
  }

  const getGradeColor = (percentage: number) => {
    if (percentage >= 90) return 'text-green-600'
    if (percentage >= 75) return 'text-blue-600'
    if (percentage >= 60) return 'text-yellow-600'
    return 'text-red-600'
  }

  const getGradeBg = (percentage: number) => {
    if (percentage >= 90) return 'bg-green-50 border-green-200'
    if (percentage >= 75) return 'bg-blue-50 border-blue-200'
    if (percentage >= 60) return 'bg-yellow-50 border-yellow-200'
    return 'bg-red-50 border-red-200'
  }

  if (loading) return <div>Loading...</div>

  const averagePercentage = results.length > 0
    ? results.reduce((sum, r) => sum + (r.Percentage || 0), 0) / results.length
    : 0

  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-8">My Results</h1>

      {results.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          <div className="bg-white p-6 rounded-lg shadow-md border-l-4 border-blue-600">
            <div className="flex items-center mb-2">
              <Award className="h-6 w-6 text-blue-600 mr-2" />
              <h3 className="text-lg font-semibold text-gray-900">Total Exams</h3>
            </div>
            <p className="text-4xl font-bold text-blue-600">{results.length}</p>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md border-l-4 border-green-600">
            <div className="flex items-center mb-2">
              <TrendingUp className="h-6 w-6 text-green-600 mr-2" />
              <h3 className="text-lg font-semibold text-gray-900">Average Score</h3>
            </div>
            <p className="text-4xl font-bold text-green-600">{averagePercentage.toFixed(2)}%</p>
          </div>
        </div>
      )}

      {results.length === 0 ? (
        <div className="bg-white p-8 rounded-lg shadow-md text-center">
          <Award className="h-16 w-16 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-600 text-lg">No exam results yet</p>
        </div>
      ) : (
        <div className="space-y-4">
          {results.map((result) => (
            <div
              key={result.StudentExamID}
              className={`bg-white p-6 rounded-lg shadow-md border-2 ${getGradeBg(result.Percentage || 0)}`}
            >
              <div className="flex justify-between items-start mb-4">
                <div>
                  <h3 className="text-xl font-semibold text-gray-900">
                    Exam #{result.Exam.ExamID}
                  </h3>
                  <p className="text-gray-600">
                    Date: {new Date(result.Exam.ExamDate).toLocaleDateString()}
                  </p>
                </div>
                <div className="text-right">
                  <div className={`text-3xl font-bold ${getGradeColor(result.Percentage || 0)}`}>
                    {result.Percentage?.toFixed(2)}%
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-3 gap-4">
                <div className="bg-gray-50 p-3 rounded">
                  <div className="text-sm text-gray-600">Your Score</div>
                  <div className="text-lg font-semibold text-gray-900">
                    {result.TotalScore}
                  </div>
                </div>
                <div className="bg-gray-50 p-3 rounded">
                  <div className="text-sm text-gray-600">Total Grade</div>
                  <div className="text-lg font-semibold text-gray-900">
                    {result.Exam.TotalGrade}
                  </div>
                </div>
                <div className="bg-gray-50 p-3 rounded">
                  <div className="text-sm text-gray-600">Grade</div>
                  <div className={`text-lg font-semibold ${getGradeColor(result.Percentage || 0)}`}>
                    {result.Percentage >= 90 ? 'A' :
                     result.Percentage >= 75 ? 'B' :
                     result.Percentage >= 60 ? 'C' :
                     result.Percentage >= 50 ? 'D' : 'F'}
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

import { useState } from 'react'
import { supabase } from '../lib/supabase'
import { FileText } from 'lucide-react'

export default function Reports() {
  const [reportType, setReportType] = useState('')
  const [param1, setParam1] = useState('')
  const [param2, setParam2] = useState('')
  const [results, setResults] = useState<any[]>([])
  const [loading, setLoading] = useState(false)

  const runReport = async () => {
    setLoading(true)
    setResults([])
    try {
      let query = supabase.from('').select('*')

      switch (reportType) {
        case 'students-by-track':
          query = supabase
            .from('Student')
            .select('*')
            .eq('TrackID', parseInt(param1))
          break

        case 'student-grades':
          const { data: studentExams } = await supabase
            .from('Student_Exam')
            .select(`
              *,
              Exam (
                ExamID,
                ExamDate,
                TotalGrade
              )
            `)
            .eq('StudentID', parseInt(param1))
          setResults(studentExams || [])
          setLoading(false)
          return

        case 'instructor-courses':
          const { data: instructorCourses } = await supabase
            .from('Instructor_Course')
            .select(`
              Course (
                CourseID,
                CourseName
              )
            `)
            .eq('InstructorID', parseInt(param1))
          setResults(instructorCourses || [])
          setLoading(false)
          return

        case 'course-topics':
          const { data: courseTopics } = await supabase
            .from('Course_Topic')
            .select(`
              Topic (
                TopicID,
                TopicName,
                TopicDescription
              )
            `)
            .eq('CourseID', parseInt(param1))
          setResults(courseTopics || [])
          setLoading(false)
          return

        case 'exam-questions':
          const { data: examQuestions } = await supabase
            .from('Exam_Question')
            .select(`
              QuestionOrder,
              Question (
                QuestionID,
                QuestionText,
                QuestionType,
                QuestionMark
              )
            `)
            .eq('ExamID', parseInt(param1))
            .order('QuestionOrder')
          setResults(examQuestions || [])
          setLoading(false)
          return

        case 'student-exam-answers':
          const { data: studentAnswers } = await supabase
            .from('Student_Exam')
            .select('StudentExamID')
            .eq('StudentID', parseInt(param1))
            .eq('ExamID', parseInt(param2))
            .maybeSingle()

          if (studentAnswers) {
            const { data: answers } = await supabase
              .from('Student_Answer')
              .select(`
                *,
                Question (
                  QuestionText,
                  QuestionMark
                ),
                Choice:AnswerID (
                  ChoiceLabel,
                  ChoiceText
                )
              `)
              .eq('StudentExamID', studentAnswers.StudentExamID)
            setResults(answers || [])
          }
          setLoading(false)
          return

        default:
          break
      }

      const { data, error } = await query
      if (error) throw error
      setResults(data || [])
    } catch (error) {
      console.error('Error running report:', error)
      alert('Error running report')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Reports</h1>

      <div className="bg-white p-6 rounded-lg shadow-md mb-6">
        <div className="grid grid-cols-1 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Select Report</label>
            <select
              value={reportType}
              onChange={(e) => {
                setReportType(e.target.value)
                setResults([])
                setParam1('')
                setParam2('')
              }}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Choose a report...</option>
              <option value="students-by-track">1. Students by Track ID</option>
              <option value="student-grades">2. Student Grades by Student ID</option>
              <option value="instructor-courses">3. Instructor Courses by Instructor ID</option>
              <option value="course-topics">4. Course Topics by Course ID</option>
              <option value="exam-questions">5. Exam Questions by Exam ID</option>
              <option value="student-exam-answers">6. Student Exam Answers (Student ID + Exam ID)</option>
            </select>
          </div>

          {reportType && (
            <>
              {reportType !== 'student-exam-answers' && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    {reportType === 'students-by-track' && 'Track ID'}
                    {reportType === 'student-grades' && 'Student ID'}
                    {reportType === 'instructor-courses' && 'Instructor ID'}
                    {reportType === 'course-topics' && 'Course ID'}
                    {reportType === 'exam-questions' && 'Exam ID'}
                  </label>
                  <input
                    type="number"
                    value={param1}
                    onChange={(e) => setParam1(e.target.value)}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                  />
                </div>
              )}

              {reportType === 'student-exam-answers' && (
                <>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Student ID</label>
                    <input
                      type="number"
                      value={param1}
                      onChange={(e) => setParam1(e.target.value)}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Exam ID</label>
                    <input
                      type="number"
                      value={param2}
                      onChange={(e) => setParam2(e.target.value)}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    />
                  </div>
                </>
              )}

              <button
                onClick={runReport}
                disabled={loading || !param1 || (reportType === 'student-exam-answers' && !param2)}
                className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors disabled:bg-blue-400 flex items-center"
              >
                <FileText className="h-5 w-5 mr-2" />
                {loading ? 'Loading...' : 'Run Report'}
              </button>
            </>
          )}
        </div>
      </div>

      {results.length > 0 && (
        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-xl font-semibold mb-4">Results ({results.length})</h2>
          <div className="overflow-x-auto">
            <pre className="bg-gray-50 p-4 rounded text-sm overflow-auto">
              {JSON.stringify(results, null, 2)}
            </pre>
          </div>
        </div>
      )}
    </div>
  )
}

import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { supabase } from '../../lib/supabase'
import { useAuth } from '../../contexts/AuthContext'
import { Question, Choice } from '../../types/database'
import { Clock, CheckCircle } from 'lucide-react'

interface ExamQuestion extends Question {
  choices: Choice[]
}

export default function TakeExam() {
  const { examId } = useParams()
  const { userId } = useAuth()
  const navigate = useNavigate()
  const [questions, setQuestions] = useState<ExamQuestion[]>([])
  const [answers, setAnswers] = useState<{ [key: number]: number }>({})
  const [studentExamId, setStudentExamId] = useState<number | null>(null)
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [exam, setExam] = useState<any>(null)

  useEffect(() => {
    if (userId && examId) {
      loadExam()
    }
  }, [userId, examId])

  const loadExam = async () => {
    try {
      const { data: examData, error: examError } = await supabase
        .from('Exam')
        .select('*')
        .eq('ExamID', examId)
        .single()

      if (examError) throw examError
      setExam(examData)

      const { data: studentExamData, error: studentExamError } = await supabase
        .from('Student_Exam')
        .select('StudentExamID')
        .eq('StudentID', userId)
        .eq('ExamID', examId)
        .maybeSingle()

      if (studentExamError) throw studentExamError

      if (!studentExamData) {
        alert('You are not registered for this exam')
        navigate('/student/exams')
        return
      }

      setStudentExamId(studentExamData.StudentExamID)

      const { data: examQuestions, error: questionsError } = await supabase
        .from('Exam_Question')
        .select('QuestionID')
        .eq('ExamID', examId)
        .order('QuestionOrder')

      if (questionsError) throw questionsError

      const questionsWithChoices: ExamQuestion[] = []
      for (const eq of examQuestions) {
        const { data: question, error: qError } = await supabase
          .from('Question')
          .select('*')
          .eq('QuestionID', eq.QuestionID)
          .single()

        if (qError) throw qError

        const { data: choices, error: cError } = await supabase
          .from('Choice')
          .select('*')
          .eq('QuestionID', eq.QuestionID)
          .order('ChoiceLabel')

        if (cError) throw cError

        questionsWithChoices.push({ ...question, choices })
      }

      setQuestions(questionsWithChoices)

      const { data: existingAnswers } = await supabase
        .from('Student_Answer')
        .select('QuestionID, AnswerID')
        .eq('StudentExamID', studentExamData.StudentExamID)

      if (existingAnswers) {
        const answersMap: { [key: number]: number } = {}
        existingAnswers.forEach(a => {
          if (a.AnswerID) answersMap[a.QuestionID] = a.AnswerID
        })
        setAnswers(answersMap)
      }
    } catch (error) {
      console.error('Error loading exam:', error)
      alert('Error loading exam')
    } finally {
      setLoading(false)
    }
  }

  const handleAnswerChange = async (questionId: number, choiceId: number) => {
    setAnswers(prev => ({ ...prev, [questionId]: choiceId }))

    if (studentExamId) {
      try {
        const { data: existingAnswer } = await supabase
          .from('Student_Answer')
          .select('StudentAnswerID')
          .eq('StudentExamID', studentExamId)
          .eq('QuestionID', questionId)
          .maybeSingle()

        const { data: choice } = await supabase
          .from('Choice')
          .select('IsCorrectChoice')
          .eq('ChoiceID', choiceId)
          .single()

        const { data: question } = await supabase
          .from('Question')
          .select('QuestionMark')
          .eq('QuestionID', questionId)
          .single()

        const isCorrect = choice?.IsCorrectChoice || false
        const mark = isCorrect ? (question?.QuestionMark || 0) : 0

        if (existingAnswer) {
          await supabase
            .from('Student_Answer')
            .update({
              AnswerID: choiceId,
              IsCorrect: isCorrect,
              Mark: mark
            })
            .eq('StudentAnswerID', existingAnswer.StudentAnswerID)
        } else {
          await supabase
            .from('Student_Answer')
            .insert({
              StudentExamID: studentExamId,
              QuestionID: questionId,
              AnswerID: choiceId,
              IsCorrect: isCorrect,
              Mark: mark
            })
        }
      } catch (error) {
        console.error('Error saving answer:', error)
      }
    }
  }

  const handleSubmit = async () => {
    if (!confirm('Are you sure you want to submit your exam?')) return

    setSubmitting(true)
    try {
      if (studentExamId) {
        const { data: allAnswers } = await supabase
          .from('Student_Answer')
          .select('Mark')
          .eq('StudentExamID', studentExamId)

        const totalScore = allAnswers?.reduce((sum, a) => sum + (a.Mark || 0), 0) || 0
        const percentage = exam ? (totalScore / exam.TotalGrade) * 100 : 0

        await supabase
          .from('Student_Exam')
          .update({
            TotalScore: totalScore,
            Percentage: percentage
          })
          .eq('StudentExamID', studentExamId)
      }

      alert('Exam submitted successfully!')
      navigate('/student/results')
    } catch (error) {
      console.error('Error submitting exam:', error)
      alert('Error submitting exam')
    } finally {
      setSubmitting(false)
    }
  }

  if (loading) return <div>Loading exam...</div>

  return (
    <div>
      <div className="bg-white p-6 rounded-lg shadow-md mb-6">
        <div className="flex justify-between items-center">
          <h1 className="text-3xl font-bold text-gray-900">Exam {examId}</h1>
          {exam && (
            <div className="flex items-center text-gray-600">
              <Clock className="h-5 w-5 mr-2" />
              <span>Total Grade: {exam.TotalGrade}</span>
            </div>
          )}
        </div>
      </div>

      <div className="space-y-6">
        {questions.map((question, index) => (
          <div key={question.QuestionID} className="bg-white p-6 rounded-lg shadow-md">
            <div className="mb-4">
              <div className="flex items-center gap-4 mb-2">
                <span className="font-semibold text-blue-600">Question {index + 1}</span>
                <span className="text-sm text-gray-600">{question.QuestionMark} marks</span>
                <span className={`px-2 py-1 rounded text-xs font-semibold ${
                  question.QuestionType === 'M' ? 'bg-blue-100 text-blue-800' : 'bg-green-100 text-green-800'
                }`}>
                  {question.QuestionType === 'M' ? 'MCQ' : 'True/False'}
                </span>
              </div>
              <p className="text-gray-900">{question.QuestionText}</p>
            </div>

            <div className="space-y-2">
              {question.choices.map(choice => (
                <label
                  key={choice.ChoiceID}
                  className={`flex items-center p-3 rounded-lg border-2 cursor-pointer transition-all ${
                    answers[question.QuestionID] === choice.ChoiceID
                      ? 'border-blue-600 bg-blue-50'
                      : 'border-gray-200 hover:border-blue-300'
                  }`}
                >
                  <input
                    type="radio"
                    name={`question-${question.QuestionID}`}
                    checked={answers[question.QuestionID] === choice.ChoiceID}
                    onChange={() => handleAnswerChange(question.QuestionID, choice.ChoiceID)}
                    className="mr-3"
                  />
                  <span className="font-semibold mr-2">{choice.ChoiceLabel}.</span>
                  <span>{choice.ChoiceText}</span>
                </label>
              ))}
            </div>
          </div>
        ))}
      </div>

      <div className="mt-8 flex justify-center">
        <button
          onClick={handleSubmit}
          disabled={submitting}
          className="bg-green-600 text-white px-8 py-3 rounded-lg hover:bg-green-700 transition-colors disabled:bg-green-400 font-semibold flex items-center"
        >
          <CheckCircle className="h-5 w-5 mr-2" />
          {submitting ? 'Submitting...' : 'Submit Exam'}
        </button>
      </div>
    </div>
  )
}

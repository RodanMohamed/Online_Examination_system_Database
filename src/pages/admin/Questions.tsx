import { useState, useEffect } from 'react'
import { supabase } from '../../lib/supabase'
import { Question, Choice, Course } from '../../types/database'
import { Plus, Trash2 } from 'lucide-react'

export default function Questions() {
  const [questions, setQuestions] = useState<Question[]>([])
  const [courses, setCourses] = useState<Course[]>([])
  const [choices, setChoices] = useState<{ [key: number]: Choice[] }>({})
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [formData, setFormData] = useState({
    QuestionText: '',
    QuestionType: 'M' as 'M' | 'T',
    QuestionMark: 1,
    CourseID: 0,
    choices: [
      { ChoiceLabel: 'A', ChoiceText: '', IsCorrectChoice: false },
      { ChoiceLabel: 'B', ChoiceText: '', IsCorrectChoice: false },
      { ChoiceLabel: 'C', ChoiceText: '', IsCorrectChoice: false },
      { ChoiceLabel: 'D', ChoiceText: '', IsCorrectChoice: false }
    ]
  })

  useEffect(() => {
    fetchQuestions()
    fetchCourses()
  }, [])

  const fetchCourses = async () => {
    try {
      const { data, error } = await supabase
        .from('Course')
        .select('*')
        .order('CourseName')

      if (error) throw error
      setCourses(data || [])
    } catch (error) {
      console.error('Error fetching courses:', error)
    }
  }

  const fetchQuestions = async () => {
    try {
      const { data, error } = await supabase
        .from('Question')
        .select('*')
        .order('QuestionID', { ascending: false })

      if (error) throw error
      setQuestions(data || [])

      data?.forEach(question => {
        fetchChoicesForQuestion(question.QuestionID)
      })
    } catch (error) {
      console.error('Error fetching questions:', error)
    } finally {
      setLoading(false)
    }
  }

  const fetchChoicesForQuestion = async (questionId: number) => {
    try {
      const { data, error } = await supabase
        .from('Choice')
        .select('*')
        .eq('QuestionID', questionId)
        .order('ChoiceLabel')

      if (error) throw error
      setChoices(prev => ({ ...prev, [questionId]: data || [] }))
    } catch (error) {
      console.error('Error fetching choices:', error)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      const { data: questionData, error: questionError } = await supabase
        .from('Question')
        .insert([{
          QuestionText: formData.QuestionText,
          QuestionType: formData.QuestionType,
          QuestionMark: formData.QuestionMark,
          CourseID: formData.CourseID
        }])
        .select()

      if (questionError) throw questionError
      if (!questionData || questionData.length === 0) throw new Error('Failed to create question')

      const questionId = questionData[0].QuestionID

      const choicesToInsert = formData.choices.filter(c => c.ChoiceText.trim() !== '')
      if (choicesToInsert.length > 0) {
        const { error: choicesError } = await supabase
          .from('Choice')
          .insert(choicesToInsert.map(choice => ({
            QuestionID: questionId,
            ChoiceLabel: choice.ChoiceLabel,
            ChoiceText: choice.ChoiceText,
            IsCorrectChoice: choice.IsCorrectChoice
          })))

        if (choicesError) throw choicesError
      }

      setShowForm(false)
      setFormData({
        QuestionText: '',
        QuestionType: 'M',
        QuestionMark: 1,
        CourseID: 0,
        choices: [
          { ChoiceLabel: 'A', ChoiceText: '', IsCorrectChoice: false },
          { ChoiceLabel: 'B', ChoiceText: '', IsCorrectChoice: false },
          { ChoiceLabel: 'C', ChoiceText: '', IsCorrectChoice: false },
          { ChoiceLabel: 'D', ChoiceText: '', IsCorrectChoice: false }
        ]
      })
      fetchQuestions()
    } catch (error) {
      console.error('Error saving question:', error)
      alert('Error saving question')
    }
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Are you sure you want to delete this question?')) return

    try {
      const { error } = await supabase
        .from('Question')
        .delete()
        .eq('QuestionID', id)

      if (error) throw error
      fetchQuestions()
    } catch (error) {
      console.error('Error deleting question:', error)
      alert('Error deleting question')
    }
  }

  if (loading) return <div>Loading...</div>

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Questions</h1>
        <button
          onClick={() => setShowForm(true)}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Question
        </button>
      </div>

      {showForm && (
        <div className="bg-white p-6 rounded-lg shadow-md mb-6">
          <h2 className="text-xl font-semibold mb-4">Add New Question</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Question Text</label>
              <textarea
                value={formData.QuestionText}
                onChange={(e) => setFormData({ ...formData, QuestionText: e.target.value })}
                required
                rows={3}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div className="grid grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Type</label>
                <select
                  value={formData.QuestionType}
                  onChange={(e) => setFormData({ ...formData, QuestionType: e.target.value as 'M' | 'T' })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                >
                  <option value="M">MCQ</option>
                  <option value="T">True/False</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Mark</label>
                <input
                  type="number"
                  step="0.5"
                  value={formData.QuestionMark}
                  onChange={(e) => setFormData({ ...formData, QuestionMark: parseFloat(e.target.value) })}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Course</label>
                <select
                  value={formData.CourseID}
                  onChange={(e) => setFormData({ ...formData, CourseID: parseInt(e.target.value) })}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                >
                  <option value={0}>Select Course</option>
                  {courses.map(course => (
                    <option key={course.CourseID} value={course.CourseID}>
                      {course.CourseName}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Choices</label>
              {formData.choices.map((choice, index) => (
                <div key={index} className="flex items-center gap-4 mb-2">
                  <span className="font-semibold w-8">{choice.ChoiceLabel}</span>
                  <input
                    type="text"
                    value={choice.ChoiceText}
                    onChange={(e) => {
                      const newChoices = [...formData.choices]
                      newChoices[index].ChoiceText = e.target.value
                      setFormData({ ...formData, choices: newChoices })
                    }}
                    className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    placeholder="Choice text"
                  />
                  <label className="flex items-center">
                    <input
                      type="checkbox"
                      checked={choice.IsCorrectChoice}
                      onChange={(e) => {
                        const newChoices = [...formData.choices]
                        newChoices[index].IsCorrectChoice = e.target.checked
                        setFormData({ ...formData, choices: newChoices })
                      }}
                      className="mr-2"
                    />
                    Correct
                  </label>
                </div>
              ))}
            </div>

            <div className="flex gap-4">
              <button
                type="submit"
                className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors"
              >
                Add Question
              </button>
              <button
                type="button"
                onClick={() => setShowForm(false)}
                className="bg-gray-300 text-gray-700 px-6 py-2 rounded-lg hover:bg-gray-400 transition-colors"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      )}

      <div className="space-y-4">
        {questions.map((question) => (
          <div key={question.QuestionID} className="bg-white p-6 rounded-lg shadow-md">
            <div className="flex justify-between items-start mb-4">
              <div className="flex-1">
                <div className="flex items-center gap-4 mb-2">
                  <span className="text-sm font-semibold text-gray-500">Q{question.QuestionID}</span>
                  <span className={`px-2 py-1 rounded text-xs font-semibold ${
                    question.QuestionType === 'M' ? 'bg-blue-100 text-blue-800' : 'bg-green-100 text-green-800'
                  }`}>
                    {question.QuestionType === 'M' ? 'MCQ' : 'True/False'}
                  </span>
                  <span className="text-sm text-gray-600">Mark: {question.QuestionMark}</span>
                </div>
                <p className="text-gray-900 mb-4">{question.QuestionText}</p>

                {choices[question.QuestionID] && (
                  <div className="space-y-2">
                    {choices[question.QuestionID].map(choice => (
                      <div key={choice.ChoiceID} className={`flex items-center gap-2 p-2 rounded ${
                        choice.IsCorrectChoice ? 'bg-green-50 border border-green-200' : 'bg-gray-50'
                      }`}>
                        <span className="font-semibold">{choice.ChoiceLabel}.</span>
                        <span>{choice.ChoiceText}</span>
                        {choice.IsCorrectChoice && (
                          <span className="ml-auto text-green-600 text-sm font-semibold">Correct</span>
                        )}
                      </div>
                    ))}
                  </div>
                )}
              </div>
              <button
                onClick={() => handleDelete(question.QuestionID)}
                className="text-red-600 hover:text-red-900 ml-4"
              >
                <Trash2 className="h-5 w-5" />
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

import { useState, useEffect } from 'react'
import { supabase } from '../../lib/supabase'
import { Course } from '../../types/database'
import { Plus, Edit, Trash2 } from 'lucide-react'

export default function Courses() {
  const [courses, setCourses] = useState<Course[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [editingCourse, setEditingCourse] = useState<Course | null>(null)
  const [formData, setFormData] = useState({
    CourseName: '',
    CourseDescription: ''
  })

  useEffect(() => {
    fetchCourses()
  }, [])

  const fetchCourses = async () => {
    try {
      const { data, error } = await supabase
        .from('Course')
        .select('*')
        .order('CourseID', { ascending: false })

      if (error) throw error
      setCourses(data || [])
    } catch (error) {
      console.error('Error fetching courses:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      if (editingCourse) {
        const { error } = await supabase
          .from('Course')
          .update(formData)
          .eq('CourseID', editingCourse.CourseID)

        if (error) throw error
      } else {
        const { error } = await supabase
          .from('Course')
          .insert([formData])

        if (error) throw error
      }

      setShowForm(false)
      setEditingCourse(null)
      setFormData({ CourseName: '', CourseDescription: '' })
      fetchCourses()
    } catch (error) {
      console.error('Error saving course:', error)
      alert('Error saving course')
    }
  }

  const handleEdit = (course: Course) => {
    setEditingCourse(course)
    setFormData({
      CourseName: course.CourseName,
      CourseDescription: course.CourseDescription || ''
    })
    setShowForm(true)
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Are you sure you want to delete this course?')) return

    try {
      const { error } = await supabase
        .from('Course')
        .delete()
        .eq('CourseID', id)

      if (error) throw error
      fetchCourses()
    } catch (error) {
      console.error('Error deleting course:', error)
      alert('Error deleting course')
    }
  }

  if (loading) return <div>Loading...</div>

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Courses</h1>
        <button
          onClick={() => {
            setShowForm(true)
            setEditingCourse(null)
            setFormData({ CourseName: '', CourseDescription: '' })
          }}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Course
        </button>
      </div>

      {showForm && (
        <div className="bg-white p-6 rounded-lg shadow-md mb-6">
          <h2 className="text-xl font-semibold mb-4">
            {editingCourse ? 'Edit Course' : 'Add New Course'}
          </h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Course Name</label>
              <input
                type="text"
                value={formData.CourseName}
                onChange={(e) => setFormData({ ...formData, CourseName: e.target.value })}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Description</label>
              <textarea
                value={formData.CourseDescription}
                onChange={(e) => setFormData({ ...formData, CourseDescription: e.target.value })}
                rows={3}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div className="flex gap-4">
              <button
                type="submit"
                className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors"
              >
                {editingCourse ? 'Update' : 'Add'} Course
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

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {courses.map((course) => (
          <div key={course.CourseID} className="bg-white p-6 rounded-lg shadow-md border-l-4 border-blue-600">
            <div className="flex justify-between items-start mb-4">
              <h3 className="text-lg font-semibold text-gray-900">{course.CourseName}</h3>
              <div className="flex gap-2">
                <button
                  onClick={() => handleEdit(course)}
                  className="text-blue-600 hover:text-blue-900"
                >
                  <Edit className="h-5 w-5" />
                </button>
                <button
                  onClick={() => handleDelete(course.CourseID)}
                  className="text-red-600 hover:text-red-900"
                >
                  <Trash2 className="h-5 w-5" />
                </button>
              </div>
            </div>
            <p className="text-gray-600 text-sm mb-2">ID: {course.CourseID}</p>
            {course.CourseDescription && (
              <p className="text-gray-700">{course.CourseDescription}</p>
            )}
          </div>
        ))}
      </div>
    </div>
  )
}

import { useState, useEffect } from 'react'
import { supabase } from '../../lib/supabase'
import { Student, Track } from '../../types/database'
import { Plus, Edit, Trash2 } from 'lucide-react'

export default function Students() {
  const [students, setStudents] = useState<Student[]>([])
  const [tracks, setTracks] = useState<Track[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [editingStudent, setEditingStudent] = useState<Student | null>(null)
  const [formData, setFormData] = useState({
    FirstName: '',
    LastName: '',
    Email: '',
    Phone: '',
    TrackID: 0
  })

  useEffect(() => {
    fetchStudents()
    fetchTracks()
  }, [])

  const fetchStudents = async () => {
    try {
      const { data, error } = await supabase
        .from('Student')
        .select('*')
        .order('StudentID', { ascending: false })

      if (error) throw error
      setStudents(data || [])
    } catch (error) {
      console.error('Error fetching students:', error)
    } finally {
      setLoading(false)
    }
  }

  const fetchTracks = async () => {
    try {
      const { data, error } = await supabase
        .from('Track')
        .select('*')
        .order('TrackName')

      if (error) throw error
      setTracks(data || [])
    } catch (error) {
      console.error('Error fetching tracks:', error)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      if (editingStudent) {
        const { error } = await supabase
          .from('Student')
          .update(formData)
          .eq('StudentID', editingStudent.StudentID)

        if (error) throw error
      } else {
        const { error } = await supabase
          .from('Student')
          .insert([formData])

        if (error) throw error
      }

      setShowForm(false)
      setEditingStudent(null)
      setFormData({ FirstName: '', LastName: '', Email: '', Phone: '', TrackID: 0 })
      fetchStudents()
    } catch (error) {
      console.error('Error saving student:', error)
      alert('Error saving student')
    }
  }

  const handleEdit = (student: Student) => {
    setEditingStudent(student)
    setFormData({
      FirstName: student.FirstName,
      LastName: student.LastName,
      Email: student.Email,
      Phone: student.Phone || '',
      TrackID: student.TrackID || 0
    })
    setShowForm(true)
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Are you sure you want to delete this student?')) return

    try {
      const { error } = await supabase
        .from('Student')
        .delete()
        .eq('StudentID', id)

      if (error) throw error
      fetchStudents()
    } catch (error) {
      console.error('Error deleting student:', error)
      alert('Error deleting student')
    }
  }

  if (loading) return <div>Loading...</div>

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Students</h1>
        <button
          onClick={() => {
            setShowForm(true)
            setEditingStudent(null)
            setFormData({ FirstName: '', LastName: '', Email: '', Phone: '', TrackID: 0 })
          }}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Student
        </button>
      </div>

      {showForm && (
        <div className="bg-white p-6 rounded-lg shadow-md mb-6">
          <h2 className="text-xl font-semibold mb-4">
            {editingStudent ? 'Edit Student' : 'Add New Student'}
          </h2>
          <form onSubmit={handleSubmit} className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">First Name</label>
              <input
                type="text"
                value={formData.FirstName}
                onChange={(e) => setFormData({ ...formData, FirstName: e.target.value })}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Last Name</label>
              <input
                type="text"
                value={formData.LastName}
                onChange={(e) => setFormData({ ...formData, LastName: e.target.value })}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
              <input
                type="email"
                value={formData.Email}
                onChange={(e) => setFormData({ ...formData, Email: e.target.value })}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Phone</label>
              <input
                type="tel"
                value={formData.Phone}
                onChange={(e) => setFormData({ ...formData, Phone: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Track</label>
              <select
                value={formData.TrackID}
                onChange={(e) => setFormData({ ...formData, TrackID: parseInt(e.target.value) })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              >
                <option value={0}>Select Track</option>
                {tracks.map(track => (
                  <option key={track.TrackID} value={track.TrackID}>
                    {track.TrackName}
                  </option>
                ))}
              </select>
            </div>
            <div className="col-span-2 flex gap-4">
              <button
                type="submit"
                className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors"
              >
                {editingStudent ? 'Update' : 'Add'} Student
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

      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Phone</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Track ID</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {students.map((student) => (
              <tr key={student.StudentID} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{student.StudentID}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {student.FirstName} {student.LastName}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{student.Email}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{student.Phone || '-'}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{student.TrackID || '-'}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <button
                    onClick={() => handleEdit(student)}
                    className="text-blue-600 hover:text-blue-900 mr-4"
                  >
                    <Edit className="h-5 w-5" />
                  </button>
                  <button
                    onClick={() => handleDelete(student.StudentID)}
                    className="text-red-600 hover:text-red-900"
                  >
                    <Trash2 className="h-5 w-5" />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

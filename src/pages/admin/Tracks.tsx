import { useState, useEffect } from 'react'
import { supabase } from '../../lib/supabase'
import { Track, Instructor } from '../../types/database'
import { Plus, Edit, Trash2 } from 'lucide-react'

export default function Tracks() {
  const [tracks, setTracks] = useState<Track[]>([])
  const [instructors, setInstructors] = useState<Instructor[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [editingTrack, setEditingTrack] = useState<Track | null>(null)
  const [formData, setFormData] = useState({
    TrackName: '',
    TrackSupervisor: 0
  })

  useEffect(() => {
    fetchTracks()
    fetchInstructors()
  }, [])

  const fetchTracks = async () => {
    try {
      const { data, error } = await supabase
        .from('Track')
        .select('*')
        .order('TrackID', { ascending: false })

      if (error) throw error
      setTracks(data || [])
    } catch (error) {
      console.error('Error fetching tracks:', error)
    } finally {
      setLoading(false)
    }
  }

  const fetchInstructors = async () => {
    try {
      const { data, error } = await supabase
        .from('Instructor')
        .select('*')
        .order('FirstName')

      if (error) throw error
      setInstructors(data || [])
    } catch (error) {
      console.error('Error fetching instructors:', error)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      const dataToSubmit = {
        TrackName: formData.TrackName,
        TrackSupervisor: formData.TrackSupervisor || null
      }

      if (editingTrack) {
        const { error } = await supabase
          .from('Track')
          .update(dataToSubmit)
          .eq('TrackID', editingTrack.TrackID)

        if (error) throw error
      } else {
        const { error } = await supabase
          .from('Track')
          .insert([dataToSubmit])

        if (error) throw error
      }

      setShowForm(false)
      setEditingTrack(null)
      setFormData({ TrackName: '', TrackSupervisor: 0 })
      fetchTracks()
    } catch (error) {
      console.error('Error saving track:', error)
      alert('Error saving track')
    }
  }

  const handleEdit = (track: Track) => {
    setEditingTrack(track)
    setFormData({
      TrackName: track.TrackName,
      TrackSupervisor: track.TrackSupervisor || 0
    })
    setShowForm(true)
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Are you sure you want to delete this track?')) return

    try {
      const { error } = await supabase
        .from('Track')
        .delete()
        .eq('TrackID', id)

      if (error) throw error
      fetchTracks()
    } catch (error) {
      console.error('Error deleting track:', error)
      alert('Error deleting track')
    }
  }

  const getSupervisorName = (supervisorId?: number) => {
    if (!supervisorId) return 'No supervisor'
    const supervisor = instructors.find(i => i.InstructorID === supervisorId)
    return supervisor ? `${supervisor.FirstName} ${supervisor.LastName}` : 'Unknown'
  }

  if (loading) return <div>Loading...</div>

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Tracks</h1>
        <button
          onClick={() => {
            setShowForm(true)
            setEditingTrack(null)
            setFormData({ TrackName: '', TrackSupervisor: 0 })
          }}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Track
        </button>
      </div>

      {showForm && (
        <div className="bg-white p-6 rounded-lg shadow-md mb-6">
          <h2 className="text-xl font-semibold mb-4">
            {editingTrack ? 'Edit Track' : 'Add New Track'}
          </h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Track Name</label>
              <input
                type="text"
                value={formData.TrackName}
                onChange={(e) => setFormData({ ...formData, TrackName: e.target.value })}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Supervisor</label>
              <select
                value={formData.TrackSupervisor}
                onChange={(e) => setFormData({ ...formData, TrackSupervisor: parseInt(e.target.value) })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              >
                <option value={0}>No Supervisor</option>
                {instructors.map(instructor => (
                  <option key={instructor.InstructorID} value={instructor.InstructorID}>
                    {instructor.FirstName} {instructor.LastName}
                  </option>
                ))}
              </select>
            </div>
            <div className="flex gap-4">
              <button
                type="submit"
                className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors"
              >
                {editingTrack ? 'Update' : 'Add'} Track
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
        {tracks.map((track) => (
          <div key={track.TrackID} className="bg-white p-6 rounded-lg shadow-md border-l-4 border-green-600">
            <div className="flex justify-between items-start mb-4">
              <h3 className="text-lg font-semibold text-gray-900">{track.TrackName}</h3>
              <div className="flex gap-2">
                <button
                  onClick={() => handleEdit(track)}
                  className="text-blue-600 hover:text-blue-900"
                >
                  <Edit className="h-5 w-5" />
                </button>
                <button
                  onClick={() => handleDelete(track.TrackID)}
                  className="text-red-600 hover:text-red-900"
                >
                  <Trash2 className="h-5 w-5" />
                </button>
              </div>
            </div>
            <p className="text-gray-600 mb-2">
              <span className="font-semibold">Supervisor:</span> {getSupervisorName(track.TrackSupervisor)}
            </p>
            <p className="text-sm text-gray-500">ID: {track.TrackID}</p>
          </div>
        ))}
      </div>
    </div>
  )
}

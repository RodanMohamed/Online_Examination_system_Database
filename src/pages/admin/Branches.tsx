import { useState, useEffect } from 'react'
import { supabase } from '../../lib/supabase'
import { Branch } from '../../types/database'
import { Plus, Edit, Trash2 } from 'lucide-react'

export default function Branches() {
  const [branches, setBranches] = useState<Branch[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [editingBranch, setEditingBranch] = useState<Branch | null>(null)
  const [formData, setFormData] = useState({
    BranchName: '',
    BranchLocation: ''
  })

  useEffect(() => {
    fetchBranches()
  }, [])

  const fetchBranches = async () => {
    try {
      const { data, error } = await supabase
        .from('Branch')
        .select('*')
        .order('BranchID', { ascending: false })

      if (error) throw error
      setBranches(data || [])
    } catch (error) {
      console.error('Error fetching branches:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      if (editingBranch) {
        const { error } = await supabase
          .from('Branch')
          .update(formData)
          .eq('BranchID', editingBranch.BranchID)

        if (error) throw error
      } else {
        const { error } = await supabase
          .from('Branch')
          .insert([formData])

        if (error) throw error
      }

      setShowForm(false)
      setEditingBranch(null)
      setFormData({ BranchName: '', BranchLocation: '' })
      fetchBranches()
    } catch (error) {
      console.error('Error saving branch:', error)
      alert('Error saving branch')
    }
  }

  const handleEdit = (branch: Branch) => {
    setEditingBranch(branch)
    setFormData({
      BranchName: branch.BranchName,
      BranchLocation: branch.BranchLocation
    })
    setShowForm(true)
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Are you sure you want to delete this branch?')) return

    try {
      const { error } = await supabase
        .from('Branch')
        .delete()
        .eq('BranchID', id)

      if (error) throw error
      fetchBranches()
    } catch (error) {
      console.error('Error deleting branch:', error)
      alert('Error deleting branch')
    }
  }

  if (loading) return <div>Loading...</div>

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Branches</h1>
        <button
          onClick={() => {
            setShowForm(true)
            setEditingBranch(null)
            setFormData({ BranchName: '', BranchLocation: '' })
          }}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Branch
        </button>
      </div>

      {showForm && (
        <div className="bg-white p-6 rounded-lg shadow-md mb-6">
          <h2 className="text-xl font-semibold mb-4">
            {editingBranch ? 'Edit Branch' : 'Add New Branch'}
          </h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Branch Name</label>
              <input
                type="text"
                value={formData.BranchName}
                onChange={(e) => setFormData({ ...formData, BranchName: e.target.value })}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Location</label>
              <input
                type="text"
                value={formData.BranchLocation}
                onChange={(e) => setFormData({ ...formData, BranchLocation: e.target.value })}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div className="flex gap-4">
              <button
                type="submit"
                className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors"
              >
                {editingBranch ? 'Update' : 'Add'} Branch
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
        {branches.map((branch) => (
          <div key={branch.BranchID} className="bg-white p-6 rounded-lg shadow-md border-l-4 border-blue-600">
            <div className="flex justify-between items-start mb-4">
              <h3 className="text-lg font-semibold text-gray-900">{branch.BranchName}</h3>
              <div className="flex gap-2">
                <button
                  onClick={() => handleEdit(branch)}
                  className="text-blue-600 hover:text-blue-900"
                >
                  <Edit className="h-5 w-5" />
                </button>
                <button
                  onClick={() => handleDelete(branch.BranchID)}
                  className="text-red-600 hover:text-red-900"
                >
                  <Trash2 className="h-5 w-5" />
                </button>
              </div>
            </div>
            <p className="text-gray-600 mb-2">
              <span className="font-semibold">Location:</span> {branch.BranchLocation}
            </p>
            <p className="text-sm text-gray-500">ID: {branch.BranchID}</p>
          </div>
        ))}
      </div>
    </div>
  )
}

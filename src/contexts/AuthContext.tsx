import { createContext, useContext, useEffect, useState, ReactNode } from 'react'
import { User, Session } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'
import { UserRole } from '../types/database'

interface AuthContextType {
  user: User | null
  session: Session | null
  userRole: UserRole | null
  userId: number | null
  loading: boolean
  signIn: (email: string, password: string) => Promise<void>
  signUp: (email: string, password: string, role: UserRole, userData: any) => Promise<void>
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [userRole, setUserRole] = useState<UserRole | null>(null)
  const [userId, setUserId] = useState<number | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      setUser(session?.user ?? null)
      if (session?.user) {
        fetchUserRole(session.user.id)
      } else {
        setLoading(false)
      }
    })

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session)
      setUser(session?.user ?? null)
      if (session?.user) {
        fetchUserRole(session.user.id)
      } else {
        setUserRole(null)
        setUserId(null)
        setLoading(false)
      }
    })

    return () => subscription.unsubscribe()
  }, [])

  const fetchUserRole = async (authUserId: string) => {
    try {
      const { data: student } = await supabase
        .from('Student')
        .select('StudentID')
        .eq('user_id', authUserId)
        .maybeSingle()

      if (student) {
        setUserRole('student')
        setUserId(student.StudentID)
        setLoading(false)
        return
      }

      const { data: instructor } = await supabase
        .from('Instructor')
        .select('InstructorID')
        .eq('user_id', authUserId)
        .maybeSingle()

      if (instructor) {
        setUserRole('instructor')
        setUserId(instructor.InstructorID)
        setLoading(false)
        return
      }

      setUserRole('admin')
      setUserId(null)
      setLoading(false)
    } catch (error) {
      console.error('Error fetching user role:', error)
      setLoading(false)
    }
  }

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
  }

  const signUp = async (email: string, password: string, role: UserRole, userData: any) => {
    const { data: authData, error: signUpError } = await supabase.auth.signUp({
      email,
      password,
    })
    if (signUpError) throw signUpError

    if (authData.user) {
      if (role === 'student') {
        const { error } = await supabase.from('Student').insert({
          FirstName: userData.firstName,
          LastName: userData.lastName,
          Email: email,
          Phone: userData.phone,
          TrackID: userData.trackId,
          user_id: authData.user.id,
        })
        if (error) throw error
      } else if (role === 'instructor') {
        const { error } = await supabase.from('Instructor').insert({
          FirstName: userData.firstName,
          LastName: userData.lastName,
          Email: email,
          Phone: userData.phone,
          user_id: authData.user.id,
        })
        if (error) throw error
      }
    }
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  return (
    <AuthContext.Provider value={{ user, session, userRole, userId, loading, signIn, signUp, signOut }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

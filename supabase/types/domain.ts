export type UserRole = 'student' | 'organizer' | 'admin'
export type EventStatus = 'pending' | 'approved' | 'rejected'

export interface Profile {
  id: string
  full_name: string
  campus: string
  role: UserRole
  created_at: string
}

export interface Event {
  id: string
  organizer_id: string
  title: string
  description: string
  venue: string
  starts_at: string
  ends_at: string
  poster_path: string | null
  status: EventStatus
  created_at: string
  updated_at: string
}

export interface EventRegistration {
  event_id: string
  user_id: string
  created_at: string
}

export interface SavedEvent {
  event_id: string
  user_id: string
  created_at: string
}

export interface EventDraft {
  title: string
  description: string
  venue: string
  starts_at: string
  ends_at: string
}

/** Client-assembled row for feed and detail. `poster_url` is derived from Storage. */
export interface EventWithMeta extends Event {
  organizer_name: string
  is_registered: boolean
  is_saved: boolean
  poster_url: string | null
}

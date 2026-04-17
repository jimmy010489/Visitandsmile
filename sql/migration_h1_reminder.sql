-- Migration : ajout du suivi rappel H-1 sur les RDV
-- A executer dans le SQL Editor Supabase

ALTER TABLE appointments
  ADD COLUMN IF NOT EXISTS h1_reminder_sent BOOLEAN DEFAULT FALSE;

-- Index pour accelerer la query du workflow SMS H-1
CREATE INDEX IF NOT EXISTS idx_appointments_h1_reminder
  ON appointments (start_time, h1_reminder_sent)
  WHERE h1_reminder_sent = FALSE;

-- Colonne pour le sync Google Calendar (stockage de l'event id retourne par GCal)
ALTER TABLE appointments
  ADD COLUMN IF NOT EXISTS google_event_id TEXT;

CREATE INDEX IF NOT EXISTS idx_appointments_google_event_id
  ON appointments (google_event_id)
  WHERE google_event_id IS NOT NULL;

-- =====================================================
-- MIGRATION : Mémoire persistante du chatbot Deadpool
-- À exécuter dans Supabase > SQL Editor
-- =====================================================

-- 1. Table d'historique des conversations
CREATE TABLE IF NOT EXISTS chatbot_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
    content TEXT NOT NULL,
    tokens_used INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. RLS
ALTER TABLE chatbot_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own chatbot history"
    ON chatbot_history FOR ALL
    USING (auth.uid() = user_id);

-- 3. Index pour récupérer rapidement les N derniers messages
CREATE INDEX IF NOT EXISTS idx_chatbot_history_user_recent
    ON chatbot_history (user_id, created_at DESC);

-- 4. Fonction : récupérer les N derniers messages (pour injection dans Claude)
CREATE OR REPLACE FUNCTION get_chatbot_history(p_user_id UUID, p_limit INT DEFAULT 10)
RETURNS TABLE (role TEXT, content TEXT, created_at TIMESTAMPTZ)
AS $$
    SELECT role, content, created_at
    FROM chatbot_history
    WHERE user_id = p_user_id
    ORDER BY created_at DESC
    LIMIT p_limit;
$$ LANGUAGE SQL SECURITY DEFINER;

-- 5. Fonction : effacer l'historique (bouton "Nouvelle conversation")
CREATE OR REPLACE FUNCTION clear_chatbot_history(p_user_id UUID)
RETURNS VOID AS $$
    DELETE FROM chatbot_history WHERE user_id = p_user_id;
$$ LANGUAGE SQL SECURITY DEFINER;

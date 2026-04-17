-- =====================================================
-- MIGRATION : Persistance LangGraph (Checkpoints)
-- À exécuter dans Supabase > SQL Editor
-- Ces tables sont requises par @langchain/langgraph-checkpoint-postgres
-- =====================================================

-- 1. Table des checkpoints (état du graphe à chaque étape)
CREATE TABLE IF NOT EXISTS langgraph_checkpoints (
    thread_id       TEXT NOT NULL,
    checkpoint_ns   TEXT NOT NULL DEFAULT '',
    checkpoint_id   TEXT NOT NULL,
    parent_checkpoint_id TEXT,
    type            TEXT,
    checkpoint      JSONB NOT NULL,
    metadata        JSONB NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (thread_id, checkpoint_ns, checkpoint_id)
);

-- 2. Table des écrits intermédiaires (résultats des nœuds)
CREATE TABLE IF NOT EXISTS langgraph_writes (
    thread_id       TEXT NOT NULL,
    checkpoint_ns   TEXT NOT NULL DEFAULT '',
    checkpoint_id   TEXT NOT NULL,
    task_id         TEXT NOT NULL,
    idx             INTEGER NOT NULL,
    channel         TEXT NOT NULL,
    type            TEXT,
    value           JSONB,
    PRIMARY KEY (thread_id, checkpoint_ns, checkpoint_id, task_id, idx)
);

-- 3. Table de migration LangGraph (versions internes)
CREATE TABLE IF NOT EXISTS langgraph_migrations (
    v INTEGER PRIMARY KEY
);

-- 4. Table custom pour le contexte métier Visit & Smile
CREATE TABLE IF NOT EXISTS langgraph_sessions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    thread_id       TEXT NOT NULL UNIQUE,
    event_type      TEXT NOT NULL,
    status          TEXT DEFAULT 'running' CHECK (status IN ('running','completed','failed','paused')),
    agents_activated TEXT[],
    summary         TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 5. RLS sur la table sessions (les autres sont internes)
ALTER TABLE langgraph_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own sessions"
    ON langgraph_sessions FOR ALL
    USING (auth.uid() = user_id);

-- 6. Index pour les requêtes fréquentes
CREATE INDEX IF NOT EXISTS idx_langgraph_checkpoints_thread
    ON langgraph_checkpoints (thread_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_langgraph_sessions_user
    ON langgraph_sessions (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_langgraph_writes_thread
    ON langgraph_writes (thread_id, checkpoint_id);

-- 7. Trigger auto-update de updated_at sur langgraph_sessions
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_langgraph_sessions_updated_at ON langgraph_sessions;
CREATE TRIGGER set_langgraph_sessions_updated_at
    BEFORE UPDATE ON langgraph_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 8. Fonction pour nettoyer les vieilles sessions (> 90 jours)
CREATE OR REPLACE FUNCTION cleanup_old_langgraph_sessions()
RETURNS void AS $$
BEGIN
    DELETE FROM langgraph_checkpoints
    WHERE thread_id IN (
        SELECT thread_id FROM langgraph_sessions
        WHERE updated_at < NOW() - INTERVAL '90 days'
    );
    DELETE FROM langgraph_writes
    WHERE thread_id IN (
        SELECT thread_id FROM langgraph_sessions
        WHERE updated_at < NOW() - INTERVAL '90 days'
    );
    DELETE FROM langgraph_sessions
    WHERE updated_at < NOW() - INTERVAL '90 days';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

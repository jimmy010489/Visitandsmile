-- =====================================================
-- MIGRATION : Suivi tokens Claude API
-- À exécuter dans Supabase > SQL Editor
-- =====================================================

-- 1. Table de tracking des appels Claude
CREATE TABLE IF NOT EXISTS claude_token_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    agent TEXT NOT NULL CHECK (agent IN ('chatbot', 'social', 'comptable', 'planning', 'other')),
    input_tokens INT NOT NULL DEFAULT 0,
    output_tokens INT NOT NULL DEFAULT 0,
    total_tokens INT GENERATED ALWAYS AS (input_tokens + output_tokens) STORED,
    cost_eur DECIMAL(10,6) GENERATED ALWAYS AS (
        -- Claude Haiku : $0.25/1M input + $1.25/1M output → converti en EUR (~0.92)
        ROUND(((input_tokens * 0.00000025) + (output_tokens * 0.00000125)) * 0.92, 6)
    ) STORED,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. RLS sur la table
ALTER TABLE claude_token_usage ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own token usage"
    ON claude_token_usage FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own token usage"
    ON claude_token_usage FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 3. Ajouter le budget mensuel dans profiles
ALTER TABLE profiles
    ADD COLUMN IF NOT EXISTS claude_monthly_budget_tokens INT DEFAULT 100000,
    ADD COLUMN IF NOT EXISTS claude_alert_threshold INT DEFAULT 80; -- % avant alerte

-- 4. Fonction : stats tokens du mois courant
CREATE OR REPLACE FUNCTION get_claude_monthly_stats(p_user_id UUID)
RETURNS TABLE (
    total_tokens_used BIGINT,
    total_cost_eur DECIMAL,
    budget_tokens INT,
    alert_threshold INT,
    usage_percent DECIMAL,
    calls_count BIGINT,
    by_agent JSONB
) AS $$
BEGIN
    RETURN QUERY
    WITH monthly AS (
        SELECT
            COALESCE(SUM(total_tokens), 0) AS tokens_used,
            COALESCE(SUM(cost_eur), 0) AS cost,
            COUNT(*) AS calls,
            jsonb_object_agg(agent, agent_tokens) AS agents
        FROM (
            SELECT
                agent,
                SUM(total_tokens) AS agent_tokens
            FROM claude_token_usage
            WHERE user_id = p_user_id
              AND created_at >= date_trunc('month', NOW())
            GROUP BY agent
        ) sub
    ),
    budget AS (
        SELECT claude_monthly_budget_tokens AS bgt, claude_alert_threshold AS threshold
        FROM profiles WHERE id = p_user_id
    )
    SELECT
        m.tokens_used,
        m.cost,
        b.bgt,
        b.threshold,
        CASE WHEN b.bgt > 0 THEN ROUND((m.tokens_used::DECIMAL / b.bgt) * 100, 1) ELSE 0 END,
        m.calls,
        COALESCE(m.agents, '{}'::JSONB)
    FROM monthly m, budget b;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Index pour les requêtes fréquentes
CREATE INDEX IF NOT EXISTS idx_claude_usage_user_month
    ON claude_token_usage (user_id, created_at DESC);

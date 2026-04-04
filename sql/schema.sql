-- ===== VISIT & SMILE — DEADPOOL IA — SCHEMA SQL =====
-- À exécuter dans Supabase SQL Editor

-- ===== EXTENSIONS =====
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===== TABLE PROFILES =====
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    business_name TEXT DEFAULT 'Visit & Smile',
    phone TEXT,
    city TEXT DEFAULT 'Orléans',
    fiscal_regime TEXT DEFAULT 'micro-entrepreneur',
    urssaf_rate DECIMAL DEFAULT 0.22,
    default_commission_rate DECIMAL DEFAULT 3,
    weekly_report_day TEXT DEFAULT 'monday',
    n8n_url TEXT,
    notifications JSONB DEFAULT '{"client": true, "rdv": true, "post": true, "declaration": true, "motivation": true, "relance": true, "birthday": true}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== TABLE SALES (Ventes) =====
CREATE TABLE sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    sale_date DATE NOT NULL,
    client_name TEXT,
    property_name TEXT NOT NULL,
    property_type TEXT,
    sale_price DECIMAL NOT NULL,
    commission_rate DECIMAL NOT NULL DEFAULT 5,
    commission_amount DECIMAL GENERATED ALWAYS AS (sale_price * commission_rate / 100) STORED,
    urssaf_amount DECIMAL GENERATED ALWAYS AS (sale_price * commission_rate / 100 * 0.22) STORED,
    net_profit DECIMAL GENERATED ALWAYS AS (sale_price * commission_rate / 100 * 0.78) STORED,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending','paid','cancelled')),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== TABLE CLIENTS =====
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    client_type TEXT DEFAULT 'buyer' CHECK (client_type IN ('buyer','seller','both')),
    status TEXT DEFAULT 'active' CHECK (status IN ('active','prospect','closed')),
    property_interest TEXT,
    budget DECIMAL,
    birthday DATE,
    purchase_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== TABLE DECLARATIONS =====
CREATE TABLE declarations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('urssaf_quarterly','income_tax','cfe')),
    label TEXT NOT NULL,
    period TEXT,
    due_date DATE NOT NULL,
    amount DECIMAL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending','submitted','paid')),
    reminder_sent BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== TABLE APPOINTMENTS (RDV) =====
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    location TEXT,
    type TEXT DEFAULT 'visit' CHECK (type IN ('visit','signing','estimation','follow_up','other')),
    status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled','confirmed','completed','cancelled')),
    source TEXT DEFAULT 'manual' CHECK (source IN ('manual','google_calendar','gmail')),
    google_event_id TEXT,
    reminder_sent BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== TABLE SOCIAL POSTS =====
CREATE TABLE social_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    platform TEXT NOT NULL CHECK (platform IN ('instagram','facebook','linkedin','tiktok')),
    content_text TEXT NOT NULL,
    media_urls TEXT[],
    hashtags TEXT[],
    scheduled_at TIMESTAMPTZ,
    published_at TIMESTAMPTZ,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft','scheduled','approved','published','failed')),
    engagement_likes INT DEFAULT 0,
    engagement_comments INT DEFAULT 0,
    engagement_shares INT DEFAULT 0,
    engagement_views INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== TABLE SOCIAL CONFIG =====
CREATE TABLE social_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    platform TEXT NOT NULL CHECK (platform IN ('instagram','facebook','linkedin','tiktok')),
    connected BOOLEAN DEFAULT false,
    preferred_format TEXT,
    tone TEXT,
    target_audience TEXT,
    frequency TEXT,
    access_token_ref TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, platform)
);

-- ===== TABLE ADS CAMPAIGNS =====
CREATE TABLE ads_campaigns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    platform TEXT NOT NULL,
    budget_monthly DECIMAL DEFAULT 50,
    objective TEXT DEFAULT 'leads',
    geo_zone TEXT DEFAULT 'Orléans + 20 km',
    active BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== TABLE RELANCE SEQUENCES =====
CREATE TABLE relance_sequences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('post_visit','cold_lead','after_sale','custom')),
    active BOOLEAN DEFAULT true,
    steps JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== TABLE MESSAGES LOG =====
CREATE TABLE messages_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    channel TEXT NOT NULL CHECK (channel IN ('email','sms')),
    type TEXT NOT NULL CHECK (type IN ('appointment_reminder','birthday','holiday','follow_up','post_visit','motivation','custom')),
    subject TEXT,
    content TEXT,
    sent_at TIMESTAMPTZ,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending','sent','failed')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== TABLE ACTIVITY FEED =====
CREATE TABLE activity_feed (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    agent TEXT NOT NULL CHECK (agent IN ('compta','social','planning','system')),
    icon TEXT,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== TABLE AGENT SETTINGS =====
CREATE TABLE agent_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    agent_name TEXT NOT NULL CHECK (agent_name IN ('compta','social','planning')),
    enabled BOOLEAN DEFAULT true,
    config_json JSONB DEFAULT '{}',
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, agent_name)
);

-- ===== TABLE SPECIAL OCCASIONS =====
CREATE TABLE special_occasions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    occasion_type TEXT NOT NULL CHECK (occasion_type IN ('birthday','christmas','new_year','purchase_anniversary','valentine','summer','easter','custom')),
    enabled BOOLEAN DEFAULT true,
    channel TEXT DEFAULT 'email' CHECK (channel IN ('email','sms','both')),
    template_text TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== ROW LEVEL SECURITY =====
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE declarations ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE ads_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE relance_sequences ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_feed ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE special_occasions ENABLE ROW LEVEL SECURITY;

-- Policies : chaque utilisateur ne voit que ses propres données
CREATE POLICY "Users can view own profile" ON profiles FOR ALL USING (id = auth.uid());
CREATE POLICY "Users can manage own sales" ON sales FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own clients" ON clients FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own declarations" ON declarations FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own appointments" ON appointments FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own social posts" ON social_posts FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own social config" ON social_config FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own ads" ON ads_campaigns FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own sequences" ON relance_sequences FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own messages" ON messages_log FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own activity" ON activity_feed FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own agent settings" ON agent_settings FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own occasions" ON special_occasions FOR ALL USING (user_id = auth.uid());

-- ===== FONCTIONS UTILITAIRES =====

-- Fonction : auto-créer le profil après inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Fonction : statistiques dashboard
CREATE OR REPLACE FUNCTION get_dashboard_stats(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'ca_month', COALESCE(SUM(CASE WHEN sale_date >= date_trunc('month', CURRENT_DATE) THEN commission_amount END), 0),
        'ca_prev_month', COALESCE(SUM(CASE WHEN sale_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month' AND sale_date < date_trunc('month', CURRENT_DATE) THEN commission_amount END), 0),
        'sales_month', COUNT(CASE WHEN sale_date >= date_trunc('month', CURRENT_DATE) THEN 1 END),
        'sales_prev_month', COUNT(CASE WHEN sale_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month' AND sale_date < date_trunc('month', CURRENT_DATE) THEN 1 END),
        'total_commission', COALESCE(SUM(commission_amount), 0),
        'total_urssaf', COALESCE(SUM(urssaf_amount), 0),
        'total_net', COALESCE(SUM(net_profit), 0),
        'margin_rate', CASE WHEN SUM(commission_amount) > 0 THEN ROUND((SUM(net_profit) / SUM(commission_amount) * 100)::numeric, 0) ELSE 0 END
    ) INTO result
    FROM sales
    WHERE user_id = p_user_id AND status != 'cancelled';

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction : CA par mois (6 derniers mois)
CREATE OR REPLACE FUNCTION get_ca_by_month(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_agg(row_to_json(t)) INTO result
    FROM (
        SELECT
            to_char(months.month, 'Mon') as label,
            to_char(months.month, 'YYYY-MM') as period,
            COALESCE(SUM(s.commission_amount), 0) as ca,
            COUNT(s.id) as sales_count
        FROM generate_series(
            date_trunc('month', CURRENT_DATE) - INTERVAL '5 months',
            date_trunc('month', CURRENT_DATE),
            '1 month'
        ) AS months(month)
        LEFT JOIN sales s ON date_trunc('month', s.sale_date) = months.month
            AND s.user_id = p_user_id
            AND s.status != 'cancelled'
        GROUP BY months.month
        ORDER BY months.month
    ) t;

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===== INDEX POUR PERFORMANCE =====
CREATE INDEX idx_sales_user_date ON sales(user_id, sale_date DESC);
CREATE INDEX idx_clients_user ON clients(user_id);
CREATE INDEX idx_appointments_user_time ON appointments(user_id, start_time);
CREATE INDEX idx_social_posts_user_status ON social_posts(user_id, status);
CREATE INDEX idx_activity_feed_user ON activity_feed(user_id, created_at DESC);
CREATE INDEX idx_declarations_user_due ON declarations(user_id, due_date);
CREATE INDEX idx_messages_log_user ON messages_log(user_id, created_at DESC);

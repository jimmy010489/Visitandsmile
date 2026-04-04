-- ===== SEED DATA — Alison Mendes — Visit & Smile =====
-- À exécuter APRÈS avoir créé le compte Alison dans Supabase Auth
-- Remplacer 'ALISON_USER_ID' par le vrai UUID de auth.users

-- Variable : remplacer par le vrai ID
-- DO $$ DECLARE alison_id UUID := 'ALISON_USER_ID'; BEGIN ... END $$;

-- Pour l'instant on utilise une fonction pour insérer avec l'ID dynamique
CREATE OR REPLACE FUNCTION seed_alison_data(alison_id UUID)
RETURNS VOID AS $$
BEGIN

-- Profil
INSERT INTO profiles (id, email, full_name, business_name, phone, city, fiscal_regime, urssaf_rate, default_commission_rate, weekly_report_day, notifications)
VALUES (alison_id, 'alison@visitandsmile.fr', 'Alison Mendes', 'Visit & Smile', '02 38 00 00 00', 'Orléans', 'micro-entrepreneur', 0.22, 3, 'monday',
    '{"client": true, "rdv": true, "post": true, "declaration": true, "motivation": true, "relance": true, "birthday": true}'::jsonb)
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    business_name = EXCLUDED.business_name,
    default_commission_rate = EXCLUDED.default_commission_rate,
    weekly_report_day = EXCLUDED.weekly_report_day,
    notifications = EXCLUDED.notifications;

-- Clients
INSERT INTO clients (user_id, first_name, last_name, email, phone, client_type, status, property_interest, budget, birthday) VALUES
    (alison_id, 'Marie', 'Dupont', 'marie.dupont@email.fr', '06 12 34 56 78', 'buyer', 'active', 'T3 Saint-Marceau', 180000, '1988-04-12'),
    (alison_id, 'Jean', 'Petit', 'jean.petit@email.fr', '06 23 45 67 89', 'buyer', 'active', 'T2 Centre-ville', 155000, '1975-09-20'),
    (alison_id, 'Paul', 'Leblanc', 'paul.leblanc@email.fr', '06 34 56 78 90', 'buyer', 'active', 'T4 Olivet', 250000, '1982-04-28'),
    (alison_id, 'Sophie', 'Laurent', 'sophie.laurent@email.fr', '06 45 67 89 01', 'seller', 'active', 'Maison La Source', 320000, '1990-07-15'),
    (alison_id, 'Anne', 'Richard', 'anne.richard@email.fr', '06 56 78 90 12', 'buyer', 'active', 'Maison Olivet', 295000, '1985-11-03');

-- Ventes
INSERT INTO sales (user_id, sale_date, client_name, property_name, property_type, sale_price, commission_rate, status, notes) VALUES
    (alison_id, '2026-03-28', 'Client existant', 'T2 Centre-ville', 'T2', 145000, 3, 'paid', 'Vente rapide'),
    (alison_id, '2026-03-15', 'Anne Richard', 'Maison Olivet', 'Maison', 320000, 3, 'paid', 'Belle propriété avec jardin'),
    (alison_id, '2026-03-08', 'Prospect', 'T3 Saint-Marceau', 'T3', 185000, 3, 'pending', 'En attente signature notaire'),
    (alison_id, '2026-02-22', 'Client recommandé', 'T4 rue Royale', 'T4', 275000, 3, 'paid', 'Recommandation Marie Dupont'),
    (alison_id, '2026-02-10', 'Client direct', 'Studio La Source', 'Studio', 95000, 3, 'paid', 'Premier achat'),
    (alison_id, '2026-01-18', 'Client Saran', 'Maison Saran', 'Maison', 210000, 3, 'paid', NULL),
    (alison_id, '2026-01-05', 'Investisseur', 'T2 Gare', 'T2', 130000, 3, 'paid', 'Investissement locatif'),
    (alison_id, '2025-12-12', 'Client fidèle', 'T3 Bannier', 'T3', 195000, 3, 'paid', NULL);

-- Déclarations
INSERT INTO declarations (user_id, type, label, period, due_date, status) VALUES
    (alison_id, 'urssaf_quarterly', 'Déclaration URSSAF Q1 2026', 'Q1_2026', '2026-01-15', 'submitted'),
    (alison_id, 'urssaf_quarterly', 'Déclaration URSSAF Q2 2026', 'Q2_2026', '2026-04-15', 'pending'),
    (alison_id, 'income_tax', 'Déclaration revenus 2025', '2025', '2026-05-30', 'pending'),
    (alison_id, 'cfe', 'CFE 2026', '2026', '2026-12-15', 'paid');

-- RDV
INSERT INTO appointments (user_id, title, description, start_time, end_time, location, type, status, source) VALUES
    (alison_id, 'Visite T3 Saint-Marceau', '65m², 185 000€ — avec Marie Dupont', '2026-04-05 14:30:00+02', '2026-04-05 15:30:00+02', 'Saint-Marceau, Orléans', 'visit', 'confirmed', 'google_calendar'),
    (alison_id, 'Visite T2 Centre-ville', '42m², 145 000€ — avec Jean Petit', '2026-04-07 10:00:00+02', '2026-04-07 11:00:00+02', 'Centre-ville, Orléans', 'visit', 'confirmed', 'gmail'),
    (alison_id, 'Signature compromis T4 Olivet', 'Compromis avec Paul Leblanc', '2026-04-07 15:00:00+02', '2026-04-07 16:30:00+02', 'Étude notariale, Orléans', 'signing', 'scheduled', 'gmail'),
    (alison_id, 'Estimation Maison La Source', 'Estimation pour Sophie Laurent', '2026-04-09 09:00:00+02', '2026-04-09 10:00:00+02', 'La Source, Orléans', 'estimation', 'scheduled', 'manual');

-- Posts réseaux sociaux
INSERT INTO social_posts (user_id, platform, content_text, hashtags, scheduled_at, status) VALUES
    (alison_id, 'instagram', 'Coup de coeur ! Ce T3 lumineux de 65m² avec balcon plein sud à Saint-Marceau n''attend que vous... ✨🏠', ARRAY['#immobilier','#orleans','#visitandsmile','#t3','#saintmarceau'], '2026-04-04 12:30:00+02', 'scheduled'),
    (alison_id, 'facebook', 'Le marché immobilier à Orléans en mars 2026 : les prix se stabilisent dans l''hyper-centre, opportunités à saisir dans le secteur La Source...', ARRAY['#immobilier','#orleans','#marchéimmo'], '2026-04-05 09:00:00+02', 'scheduled'),
    (alison_id, 'instagram', 'Visite virtuelle — Maison 5 pièces avec jardin à Olivet, 320k€ 🎬🏡', ARRAY['#immobilier','#olivet','#maison','#visitevirtuelle'], '2026-04-05 12:30:00+02', 'draft'),
    (alison_id, 'linkedin', 'Analyse du marché immobilier orléanais Q1 2026 : tendances, prix au m² et perspectives pour les investisseurs.', ARRAY['#immobilier','#investissement','#orleans'], '2026-04-06 09:00:00+02', 'draft');

-- Config réseaux sociaux
INSERT INTO social_config (user_id, platform, connected, preferred_format, tone, target_audience, frequency) VALUES
    (alison_id, 'instagram', true, 'Carrousel photos', 'Visuel & inspirant', '25-45 ans, primo-accédants, lifestyle', '2 posts/jour'),
    (alison_id, 'facebook', true, 'Article détaillé + photos', 'Informatif & convivial', '35-60 ans, familles, investisseurs locaux', '1 post/jour'),
    (alison_id, 'linkedin', true, 'Article expertise marché', 'Expert & crédible', 'Investisseurs, pros immo, cadres 30-55 ans', '3 posts/semaine'),
    (alison_id, 'tiktok', false, 'Vidéo visite dynamique', 'Fun & authentique', '18-30 ans, primo-accédants, curiosité', NULL);

-- Séquences de relance
INSERT INTO relance_sequences (user_id, name, type, active, steps) VALUES
    (alison_id, 'Post-visite', 'post_visit', true, '[
        {"delay": "J+1", "channel": "email", "action": "Email feedback visite"},
        {"delay": "J+3", "channel": "sms", "action": "SMS rappel si pas de retour"},
        {"delay": "J+7", "channel": "email", "action": "Email nouvelles propositions"},
        {"delay": "J+14", "channel": "phone", "action": "Appel (transfert Alison)"}
    ]'::jsonb),
    (alison_id, 'Lead froid', 'cold_lead', true, '[
        {"delay": "J+5", "channel": "email", "action": "Email Toujours en recherche ?"},
        {"delay": "J+15", "channel": "email", "action": "Email nouveautés du secteur"},
        {"delay": "J+30", "channel": "sms", "action": "SMS dernière tentative"}
    ]'::jsonb),
    (alison_id, 'Après-vente', 'after_sale', true, '[
        {"delay": "J+1", "channel": "email", "action": "Email félicitations + avis Google"},
        {"delay": "J+30", "channel": "email", "action": "Email Comment se passe l''installation ?"},
        {"delay": "J+90", "channel": "email", "action": "Demande de recommandation"}
    ]'::jsonb);

-- Occasions spéciales
INSERT INTO special_occasions (user_id, occasion_type, enabled, channel, template_text) VALUES
    (alison_id, 'birthday', true, 'email', 'Joyeux anniversaire {prenom} ! 🎂 Toute l''équipe Visit & Smile vous souhaite une merveilleuse journée.'),
    (alison_id, 'christmas', true, 'email', 'Joyeux Noël {prenom} ! 🎄 Que cette période de fêtes vous apporte joie et sérénité. À très bientôt !'),
    (alison_id, 'new_year', true, 'both', 'Bonne année {prenom} ! 🥂 Visit & Smile vous souhaite une année 2027 pleine de beaux projets immobiliers.'),
    (alison_id, 'purchase_anniversary', true, 'email', 'Cher(e) {prenom}, cela fait déjà 1 an que vous êtes propriétaire ! 🏠🎉 Comment vous sentez-vous dans votre nouveau chez-vous ?'),
    (alison_id, 'valentine', false, 'email', NULL),
    (alison_id, 'summer', false, 'email', NULL);

-- Agent settings
INSERT INTO agent_settings (user_id, agent_name, enabled, config_json) VALUES
    (alison_id, 'compta', true, '{
        "auto_urssaf_reminder": true,
        "reminder_days_before": 3,
        "weekly_report": true,
        "weekly_report_day": "monday"
    }'::jsonb),
    (alison_id, 'social', true, '{
        "auto_publish": false,
        "require_approval": true,
        "ads_enabled": false,
        "ads_budget": 50,
        "ads_platforms": ["facebook", "instagram"],
        "ads_objective": "leads",
        "ads_geo": "Orléans + 20 km"
    }'::jsonb),
    (alison_id, 'planning', true, '{
        "available_hours": {"start": "09:00", "end": "19:00"},
        "default_duration": 60,
        "confirmation_channel": "email_sms",
        "reminder_before": "1h_and_day_before",
        "auto_relance": true
    }'::jsonb);

-- Activité récente initiale
INSERT INTO activity_feed (user_id, agent, icon, message) VALUES
    (alison_id, 'compta', 'fa-calculator', '<strong>Déclaration URSSAF</strong> — Rappel : déclaration trimestrielle Q2 à envoyer avant le 15 avril'),
    (alison_id, 'social', 'fa-instagram', '<strong>Post publié</strong> — Nouveau T4 lumineux rue Royale — 127 likes, 8 commentaires'),
    (alison_id, 'planning', 'fa-calendar-check', '<strong>RDV confirmé</strong> — Visite T3 Saint-Marceau avec Marie Dupont, demain 14h30'),
    (alison_id, 'compta', 'fa-chart-line', '<strong>Vente enregistrée</strong> — T2 Centre-ville vendu 145 000€, commission 4 350€'),
    (alison_id, 'planning', 'fa-envelope-open', '<strong>Email reçu</strong> — Jean Petit confirme le rendez-vous de vendredi 10h');

END;
$$ LANGUAGE plpgsql;

-- UTILISATION : SELECT seed_alison_data('xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx');
-- Remplacer par l'UUID du user Alison créé dans Supabase Auth

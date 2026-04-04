# CLAUDE.md — Visit & Smile / Deadpool IA

## Projet
SaaS pour **Alison Mendes**, auto-entrepreneuse immobilier chez **Visit & Smile** (Orleans).
3 agents IA pilotes par n8n + chatbot Deadpool IA + PWA installable.

## Client
- **Alison Mendes** — auto-entrepreneuse, agence immobiliere "Visit & Smile", Orleans
- La demo a ete validee par la cliente, on construit le produit final de production

## Architecture
- **Frontend** : HTML/CSS/JS vanilla (SPA single-page), design futuriste noir & or
- **Backend** : Supabase (PostgreSQL + Auth + RLS + Realtime)
- **Automatisation** : n8n (webhooks + cron) pour les 3 agents + chatbot
- **APIs externes** : Claude API (Haiku), SendGrid, Twilio, Google Calendar, Meta Graph API
- **PWA** : manifest.json + service worker (network-first)
- **Mode dual** : DEMO (donnees en dur) / PRODUCTION (Supabase) — auto-detecte via `config.js`

## Structure des fichiers
```
visit-and-smile/
  index.html              # SPA principale (toutes les pages, modals, chatbot)
  css/style.css            # Styles complets (noir & or, responsive, print, splash)
  js/config.js             # Configuration centrale (URLs, webhooks, taux)
  js/supabase.js           # Service layer Supabase (Auth, Profile, Sales, Clients, Chatbot, Utils)
  js/app.js                # Logique applicative (~1600 lignes, navigation, modals, toasts, search, etc.)
  sql/schema.sql           # Schema PostgreSQL complet (13 tables, RLS, fonctions)
  sql/seed.sql             # Donnees de demo pour Alison
  n8n/agent-comptable.json # Workflow n8n agent comptable
  n8n/agent-planning.json  # Workflow n8n agent planning & RDV
  n8n/agent-social.json    # Workflow n8n agent reseaux sociaux
  n8n/chatbot-deadpool.json# Workflow n8n chatbot
  manifest.json            # PWA manifest
  sw.js                    # Service Worker (network-first, exclut Supabase/n8n)
  vercel.json              # Config deploiement Vercel (routes, cache, headers)
  icons/                   # Icones PWA (192x192, 512x512)
  generate_icons.py        # Script Pillow pour generer les icones
  generate_tarif.py        # Script pour generer la grille tarifaire PDF
  SETUP.md                 # Guide de deploiement production complet
  CLAUDE.md                # Documentation technique pour les sessions Claude
  server.js                # Serveur local Express pour le dev
  .claude/launch.json      # Config preview (port 3003)
```

## Pages de l'application
1. **Dashboard** — Stats CA/ventes/engagement/RDV, graphiques, etat des agents, activite recente
2. **Comptabilite** — Tableau financier, historique ventes, declarations URSSAF, export CSV
3. **Reseaux Sociaux** — 4 plateformes (Instagram/Facebook/LinkedIn/TikTok), generation IA, Ads toggle, performances, posts a venir
4. **Planning & RDV** — Sources (Google Calendar/Gmail), RDV a venir, relances, anniversaires
5. **Clients** — Tableau CRUD, fiche detail avec actions (email, RDV, modifier)
6. **Parametres** — Infos personnelles, comptabilite, connexions API, notifications

## Base de donnees (Supabase)
### Tables principales
- `profiles` — id, email, full_name, business_name, phone, city, fiscal_regime, urssaf_rate, default_commission_rate, weekly_report_day, n8n_url, notifications (JSONB)
- `sales` — ventes avec generated columns (commission_amount, urssaf_amount, net_profit)
- `clients` — acheteurs/vendeurs avec birthday, budget, property_interest
- `declarations` — declarations URSSAF/impots
- `appointments` — RDV avec type (visit/signing/estimation), source, client_id
- `social_posts` — posts programmes avec platform, hashtags, scheduled_at
- `social_config` — config par plateforme (format, ton, audience, frequence)
- `ads_campaigns` — campagnes publicitaires
- `relance_sequences` — sequences de relance J+1/J+3/J+7
- `messages_log` — historique emails/SMS envoyes
- `activity_feed` — flux d'activite en temps reel
- `agent_settings` — etat actif/inactif + config JSON par agent
- `special_occasions` — anniversaires, fetes

### RLS
Toutes les tables ont RLS active avec policy `user_id = auth.uid()`

### Fonctions SQL
- `handle_new_user()` — trigger sur auth.users pour creer le profil
- `get_dashboard_stats()` — stats CA, ventes, URSSAF du mois
- `get_ca_by_month()` — CA des 6 derniers mois

## Fonctionnalites implementees
- [x] Login/logout avec session persistante
- [x] Navigation SPA avec chargement de donnees par page
- [x] Dashboard avec graphiques animes et activite temps reel
- [x] CRUD complet : Ventes, Clients, RDV, Posts sociaux
- [x] Modal creation vente avec calcul commission/URSSAF en temps reel
- [x] Modal creation post avec generation IA (n8n webhook ou fallback demo)
- [x] Modal creation client avec tous les champs
- [x] Modal creation RDV avec pre-remplissage depuis fiche client
- [x] Fiche detail client (modal) avec email/tel cliquables + actions
- [x] Recherche globale multi-categories (clients + ventes + RDV) avec headers
- [x] Export CSV comptabilite avec totaux
- [x] Export CSV clients (prenom, nom, type, email, tel, bien, budget, anniversaire, statut, notes)
- [x] Notifications panel avec "marquer tout lu"
- [x] Chatbot Deadpool IA (n8n webhook ou fallback local)
- [x] Toggle agents actif/inactif sauvegarde dans Supabase
- [x] Toggle Ads actif/inactif
- [x] Parametres complets avec sauvegarde profil
- [x] Filtres temporels (mois/trimestre/annee)
- [x] PWA installable (manifest + service worker)
- [x] Responsive mobile (375px+), tablet, desktop
- [x] Command palette (Ctrl+K) avec navigation, actions rapides, filtrage temps reel, clavier
- [x] Mini calendrier interactif sur page Planning (navigation mois, dots RDV, agenda jour)
- [x] Raccourcis clavier (Ctrl+K = command palette, Esc = fermer panels)
- [x] Animations (compteurs, barres, slides, typing indicator)
- [x] Modifier client (modal edit pre-rempli depuis la fiche detail)
- [x] Toast notifications (feedback visuel pour toutes les actions CRUD)
- [x] Skeleton loading CSS (classes .skeleton, .skeleton-text, .skeleton-stat)
- [x] Indicateur offline PWA (banner + toast online/offline)
- [x] Dashboard agent cards cliquables (naviguent vers la page agent)
- [x] Splash screen PWA (logo anime, barre de chargement)
- [x] Chatbot enrichi (30+ reponses contextuelles : CA, clients, RDV, motivation, etc.)
- [x] Print CSS (impression propre de la page comptabilite)
- [x] Meta tags Open Graph (partage pro sur reseaux sociaux)
- [x] Favicon configuree
- [x] vercel.json (deploiement 1 clic sur Vercel)
- [x] Onboarding tour interactif (6 etapes avec spotlight, localStorage pour ne montrer qu'une fois)
- [x] Validation CSS formulaires (bordures rouge/vert sur champs invalides/valides)
- [x] package.json + .gitignore

## Workflows n8n (4 fichiers JSON importables)
1. **Agent Comptable** : resume hebdo (lundi 9h), rappels declarations, log ventes
2. **Agent Planning** : creation event Google Calendar, rappels SMS, relances auto, anniversaires
3. **Agent Social** : generation contenu IA par plateforme, publication Meta, stats
4. **Chatbot Deadpool** : webhook, contexte utilisateur, persona Claude

## Variables de configuration (config.js)
- `SUPABASE_URL` / `SUPABASE_ANON_KEY` — credentials Supabase
- `N8N_BASE_URL` — URL du serveur n8n
- `WEBHOOKS` — paths des 5 webhooks (chatbot, new-sale, new-appointment, publish-post, generate-content)
- `URSSAF_RATE` — taux URSSAF (0.22 par defaut)
- `DEFAULT_COMMISSION_RATE` — taux commission (3% par defaut)

## Design
- **Palette** : Noir profond (#030306 → #131318), Or (#d4a931), Vert (#00e676), Rouge (#ff4757)
- **Fonts** : Space Grotesk (display), Outfit (body), JetBrains Mono (data)
- **Effets** : Gold glow borders, glassmorphism, gradient subtils, animations CSS

## Deploiement
Voir `SETUP.md` pour le guide complet. Resume :
1. Creer projet Supabase → executer schema.sql → creer user → executer seed.sql
2. Configurer n8n (cloud ou self-hosted) → importer les 4 workflows → configurer credentials
3. Deployer frontend (Vercel/Cloudflare Pages) → mettre a jour config.js
4. Cout estime : ~25-35 EUR/mois

## Taches restantes pour livraison finale
- [ ] Creer le projet Supabase reel d'Alison et y injecter schema + seed
- [ ] Configurer n8n avec les vrais credentials (SendGrid, Twilio, Google Calendar, Meta, Claude API)
- [ ] Deployer le frontend sur un domaine (ex: app.visitandsmile.fr)
- [ ] Tester le flux complet end-to-end en production
- [ ] Former Alison a l'utilisation de l'app
- [ ] Configurer le domaine personnalise + SSL
- [x] ~~Onboarding tour guide~~ DONE
- [x] ~~Recherche globale multi-categories~~ DONE
- [x] ~~Command palette (Ctrl+K)~~ DONE
- [x] ~~Export clients CSV~~ DONE
- [x] ~~Mini calendrier planning~~ DONE
- [ ] Ajouter suppression client avec confirmation (optionnel)
- [ ] Ajouter drag & drop pour reordonner les posts programmes (optionnel)
- [ ] Guide utilisateur PDF-ready pour Alison (optionnel)

## Commandes dev
```bash
# Lancer le serveur local
node server.js
# → http://localhost:3003

# Generer les icones PWA
python generate_icons.py

# Generer la grille tarifaire PDF
python generate_tarif.py
```

## Notes techniques
- Le fichier `app.js` contient TOUT le JS applicatif (~1300 lignes) dans un seul DOMContentLoaded
- Le mode DEMO/PRODUCTION est determine par `isSupabaseConfigured` (compare l'URL Supabase au placeholder)
- Les donnees demo pour la recherche sont dupliquees dans `demoClients` dans app.js
- Le service worker exclut les appels Supabase et n8n du cache
- Les generated columns SQL (commission_amount, urssaf_amount, net_profit) sont calcules cote DB

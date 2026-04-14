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

## Workflows n8n (11 workflows DEPLOYES + ACTIFS sur jimmy010489.app.n8n.cloud)

### Evenementiels (webhooks)
1. **Email Confirmation RDV** (`4sXKFLUiEoR48Q71`) — declenche a chaque creation RDV, envoie email via Brevo
2. **Sync Google Calendar** (`lMzRfBzdwnSldRwE`) — declenche a chaque creation RDV, cree l'event dans le GCal d'Alison via OAuth2
3. **Nouvelle vente** (`agent-comptable` original) — webhook declenche a chaque vente
4. **Chatbot Deadpool IA** — webhook streaming pour le chatbot in-app

### Crons automatiques
5. **SMS Rappel RDV J-1** (`jMwMr5SG9fadIbpk`) — cron 18h quotidien, SMS via Brevo
6. **SMS Rappel RDV H-1** (`E8xhnDI2DmaMj6Kd`) — cron horaire, SMS via Brevo
7. **Email Anniversaire clients** (`raroE26supQB8HEs`) — cron 9h quotidien
8. **Relances J+1/J+3/J+7** (`2ACxIzKRd1ju95Ge`) — cron 10h quotidien, suite aux visites
9. **Email Resume hebdomadaire** (`AXIuA0XgdjCNpUSU`) — cron Lundi 9h
10. **Email Rappel URSSAF** (`2hLl7R1WNVjXUpJD`) — cron 20 Jan/Avr/Jul/Oct 9h
11. **Agent Social Autopost** (`jnrOJK9ZpsQ2YIjN`) — cron Lun/Mer/Ven 10h, FIFO Supabase Storage

### Integrations externes
- **Brevo** (email + SMS unifies) — sender verifie : `ghostconciergerie@gmail.com`, SMS sender : `VisitSmile`
- **Claude API** (Anthropic) — model `claude-haiku-4-5-20251001`, utilise pour generation messages + chatbot
- **Google Calendar OAuth2** — credential `azMcSe556QPb512l` dans n8n (app OAuth creee dans Google Cloud : `n8n Deadpool IA`)
- **Supabase Storage** — bucket `social-posts` pour les visuels de l'Agent Social

## Variables de configuration (config.js)
- `SUPABASE_URL` / `SUPABASE_ANON_KEY` — credentials Supabase
- `N8N_BASE_URL` — URL du serveur n8n (https://jimmy010489.app.n8n.cloud)
- `WEBHOOKS` — paths : CHATBOT, NEW_SALE, NEW_APPOINTMENT, CONFIRM_APPOINTMENT, SYNC_GCAL, PUBLISH_POST, GENERATE_CONTENT
- `URSSAF_RATE` — taux URSSAF (0.22 par defaut)
- `DEFAULT_COMMISSION_RATE` — taux commission (3% par defaut)

## Design
- **Palette** : Noir profond (#030306 → #131318), Or (#d4a931), Vert (#00e676), Rouge (#ff4757)
- **Fonts** : Space Grotesk (display), Outfit (body), JetBrains Mono (data)
- **Effets** : Gold glow borders, glassmorphism, gradient subtils, animations CSS

## Deploiement (EN PROD)
- **Frontend** : https://visit-and-smile.vercel.app (Vercel)
- **Backend** : Supabase projet `zbzicommpdsvkesqzyvb` (schema + migration h1_reminder + google_event_id appliques)
- **n8n** : https://jimmy010489.app.n8n.cloud (11 workflows actifs)
- **Voir** `ACTIVATION.md` pour les 3 etapes de setup initial (deja completees)

## Taches completees (livraison production)
- [x] Creer projet Supabase + schema + seed
- [x] Pivot SendGrid/Twilio → **Brevo** (emails + SMS unifies, sender verifie)
- [x] Deploy 11 workflows n8n via API + activation
- [x] Migration SQL (h1_reminder_sent, google_event_id)
- [x] Google Calendar OAuth2 (app Google Cloud + credential n8n + activation workflow)
- [x] Agent Social autopost (FIFO Supabase Storage + Claude caption)
- [x] Panneau Automations dans Parametres (liste 11 workflows + boutons test)
- [x] Toasts feedback sur creation RDV (email + gcal)
- [x] Deploy prod Vercel
- [x] ~~Onboarding tour guide~~
- [x] ~~Recherche globale multi-categories~~
- [x] ~~Command palette (Ctrl+K)~~
- [x] ~~Export clients CSV~~
- [x] ~~Mini calendrier planning~~
- [x] ~~Suppression client avec modal de confirmation~~
- [x] ~~Guide utilisateur integre (8 sections, imprimable)~~

## Taches restantes (post-livraison)
- [x] Test end-to-end reel — RDV cree, n8n Exec 214 OK (email Brevo + GCal + activity feed)
- [ ] Former Alison a l'utilisation de l'app
- [ ] Domaine personnalise app.visitandsmile.fr — configure sur Vercel (CNAME: app → c612396d62625409.vercel-dns-017.com.), domaine visitandsmile.fr non achete (~8€/an chez OVH/Gandi)
- [ ] Meta/Instagram tokens pour autopost — agent-social.json pret (placeholders VOTRE_FB_PAGE_ACCESS_TOKEN_ICI etc.), attente tokens Alison via developers.facebook.com
- [ ] Gmail OAuth scan inbox — fonctionnalite future, aucun workflow cree pour l'instant
- [ ] Ajouter drag & drop pour reordonner les posts programmes (optionnel)
- [x] Google OAuth "In production" — N/A : le credential Google Calendar utilise le OAuth gere par n8n (oauth.n8n.cloud), pas une app Google Cloud personnalisee. Warning "app non verifiee" = avertissement ponctuel n8n, deja accepte par Alison.

## Notes techniques complementaires
- `renderActivityMessage()` : fonction ajoutee dans app.js pour afficher balises HTML dans le feed d'activite
- User ID Alison Supabase : fa832096-ef0a-4f6e-8136-7de3e5b00a4d
- Credential n8n Google Calendar : azMcSe556QPb512l (OAuth gere n8n, Account connected)

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

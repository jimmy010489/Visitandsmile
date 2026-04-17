# Déploiement — Visit & Smile LangGraph Backend

## Prérequis

- Node.js 20+
- Compte [Railway](https://railway.app) (gratuit pour commencer)
- Supabase project déjà configuré (`zbzicommpdsvkesqzyvb`)

---

## Étape 1 — Migrations SQL Supabase

Dans **Supabase > SQL Editor**, exécuter dans cet ordre :

```
sql/migration_claude_tokens.sql
sql/migration_chatbot_memory.sql
sql/migration_langgraph_checkpoints.sql
```

---

## Étape 2 — Variables d'environnement Railway

Créer un projet Railway depuis le repo. Dans **Settings > Variables**, ajouter :

| Variable | Valeur |
|---|---|
| `ANTHROPIC_API_KEY` | sk-ant-... |
| `SUPABASE_URL` | https://zbzicommpdsvkesqzyvb.supabase.co |
| `SUPABASE_SERVICE_KEY` | eyJ... (service_role, dans Supabase > Settings > API) |
| `SUPABASE_DB_URL` | postgresql://postgres:[PASSWORD]@db.zbzicommpdsvkesqzyvb.supabase.co:5432/postgres |
| `FRONTEND_URL` | https://visit-and-smile.vercel.app |
| `PORT` | 3004 |

Le mot de passe PostgreSQL se trouve dans **Supabase > Settings > Database > Connection string**.

---

## Étape 3 — Déploiement Railway

```bash
# Depuis le dossier /backend
npm install
# Pousser sur Railway via GitHub ou CLI :
railway up
```

Railway détecte automatiquement `railway.json` et démarre avec `node api.js`.

L'URL de déploiement aura la forme : `https://visit-and-smile-backend.up.railway.app`

---

## Étape 4 — Connecter le frontend

Dans `index.html`, décommenter et remplir :

```html
<meta name="langgraph-url" content="https://visit-and-smile-backend.up.railway.app">
```

Redéployer sur Vercel.

---

## Étape 5 — Test de santé

```bash
curl https://visit-and-smile-backend.up.railway.app/api/health
# → {"status":"ok","service":"Visit & Smile LangGraph API","timestamp":"..."}
```

---

## Architecture finale

```
[Alison — Interface Vercel]
       │
       ▼
[Orchestrateur.dispatch()]     ← js/supabase.js
       │
       ├─ Primaire → LangGraph API (Railway)
       │              │
       │              ▼
       │         [Chef Agent Claude]
       │              │
       │     ┌────────┼────────┐
       │     ▼        ▼        ▼
       │  Comptable  Social  Planning
       │     │        │        │
       │     └────────┴────────┘
       │              │
       │     [PostgresSaver → Supabase]
       │
       └─ Fallback → n8n (si Railway indisponible)
```

---

## Logs en production

Dans Railway > Logs, filtrer par :
- `[Chef Agent]` — décisions d'orchestration
- `[Agent Comptable/Social/Planning]` — actions des sous-agents
- `[LangGraph]` — init et persistance

#!/usr/bin/env bash
# =====================================================
# VISIT & SMILE — Script de déploiement complet
# Exécuter depuis le dossier /backend
# Usage : bash setup.sh
# =====================================================
set -e

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

step() { echo -e "\n${CYAN}▶ $1${NC}"; }
ok()   { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════╗"
echo "║   VISIT & SMILE — LangGraph Backend Setup   ║"
echo "╚══════════════════════════════════════════════╝${NC}"

# ── 1. Vérifier .env ────────────────────────────────
step "1/5 — Vérification .env"
if [ ! -f ".env" ]; then
    cp .env.example .env
    warn ".env créé depuis .env.example — REMPLIR les valeurs avant de continuer"
    echo ""
    echo "Variables requises :"
    echo "  ANTHROPIC_API_KEY=sk-ant-..."
    echo "  SUPABASE_DB_URL=postgresql://postgres:[PASSWORD]@db.zbzicommpdsvkesqzyvb.supabase.co:5432/postgres"
    echo "  SUPABASE_URL=https://zbzicommpdsvkesqzyvb.supabase.co"
    echo "  SUPABASE_SERVICE_KEY=eyJ..."
    echo "  FRONTEND_URL=https://visit-and-smile.vercel.app"
    echo ""
    read -p "▶ Appuie sur ENTRÉE après avoir rempli .env..." _
fi

source .env

if [ -z "$ANTHROPIC_API_KEY" ] || [ "$ANTHROPIC_API_KEY" = "sk-ant-xxxxxxxxxxxxxxxxxxxxxxxxxxxx" ]; then
    echo -e "${RED}❌ ANTHROPIC_API_KEY non configurée dans .env${NC}"
    exit 1
fi
ok ".env configuré"

# ── 2. Installer les dépendances ────────────────────
step "2/5 — npm install"
npm install
ok "Dépendances installées"

# ── 3. Migrations SQL Supabase ──────────────────────
step "3/5 — Migrations SQL Supabase"

if [ -z "$SUPABASE_DB_URL" ] || [[ "$SUPABASE_DB_URL" == *"[PASSWORD]"* ]]; then
    warn "SUPABASE_DB_URL non configuré — migrations SQL à exécuter manuellement"
    echo ""
    echo "Dans Supabase > SQL Editor, exécuter dans l'ordre :"
    echo "  1. ../sql/migration_claude_tokens.sql"
    echo "  2. ../sql/migration_chatbot_memory.sql"
    echo "  3. ../sql/migration_langgraph_checkpoints.sql"
else
    # Migrations via psql si disponible
    if command -v psql &>/dev/null; then
        echo "Exécution via psql..."
        psql "$SUPABASE_DB_URL" -f ../sql/migration_claude_tokens.sql      && echo "  ✅ migration_claude_tokens.sql"
        psql "$SUPABASE_DB_URL" -f ../sql/migration_chatbot_memory.sql     && echo "  ✅ migration_chatbot_memory.sql"
        psql "$SUPABASE_DB_URL" -f ../sql/migration_langgraph_checkpoints.sql && echo "  ✅ migration_langgraph_checkpoints.sql"
        ok "Migrations SQL exécutées"
    else
        # Fallback : via node + pg
        node - <<MIGRATION_SCRIPT
import pg from 'pg';
import fs from 'fs';
const pool = new pg.Pool({ connectionString: process.env.SUPABASE_DB_URL });
const migrations = [
    '../sql/migration_claude_tokens.sql',
    '../sql/migration_chatbot_memory.sql',
    '../sql/migration_langgraph_checkpoints.sql',
];
for (const file of migrations) {
    const sql = fs.readFileSync(file, 'utf8');
    await pool.query(sql);
    console.log('✅', file);
}
await pool.end();
MIGRATION_SCRIPT
        ok "Migrations SQL exécutées"
    fi
fi

# ── 4. Test de démarrage ────────────────────────────
step "4/5 — Test démarrage serveur (5 secondes)"
node api.js &
SERVER_PID=$!
sleep 5

HEALTH=$(curl -s http://localhost:3004/api/health 2>/dev/null || echo "unreachable")
kill $SERVER_PID 2>/dev/null

if echo "$HEALTH" | grep -q '"status":"ok"'; then
    ok "Serveur démarre correctement"
else
    warn "Test serveur échoué (probablement manque Supabase DB) — vérifier .env"
    echo "Réponse: $HEALTH"
fi

# ── 5. Instructions déploiement Railway ─────────────
step "5/5 — Déploiement Railway"
if command -v railway &>/dev/null; then
    echo "Railway CLI détecté — déploiement en cours..."
    railway up --detach
    RAILWAY_URL=$(railway domain 2>/dev/null || echo "")
    if [ -n "$RAILWAY_URL" ]; then
        ok "Déployé sur Railway : https://$RAILWAY_URL"
        echo ""
        echo -e "${YELLOW}Dernière étape : décommenter dans index.html :${NC}"
        echo "  <meta name=\"langgraph-url\" content=\"https://$RAILWAY_URL\">"
    fi
else
    warn "Railway CLI non installé — déploiement manuel requis"
    echo ""
    echo "Options de déploiement :"
    echo "  A) Railway CLI : npm install -g railway && railway login && railway up"
    echo "  B) Railway Web  : railway.app > New Project > Deploy from GitHub"
    echo "     (connecter le repo, pointer sur /backend, ajouter les variables d'env)"
    echo ""
    echo "Variables d'env à copier dans Railway :"
    for var in ANTHROPIC_API_KEY SUPABASE_URL SUPABASE_SERVICE_KEY SUPABASE_DB_URL FRONTEND_URL; do
        val="${!var}"
        if [ -n "$val" ]; then
            echo "  $var=${val:0:20}..."
        fi
    done
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗"
echo "║         SETUP TERMINÉ ✅                    ║"
echo "╚══════════════════════════════════════════════╝${NC}"

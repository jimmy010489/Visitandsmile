#!/usr/bin/env bash
# =====================================================
# VISIT & SMILE — Import automatique de tous les workflows n8n
# Usage : N8N_API_KEY=xxx bash import-all.sh
# Récupérer la clé dans n8n > Settings > API > Create API Key
# =====================================================
set -e

N8N_URL="${N8N_URL:-https://jimmy010489.app.n8n.cloud}"
N8N_API_KEY="${N8N_API_KEY:-}"

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

if [ -z "$N8N_API_KEY" ]; then
    echo -e "${YELLOW}Usage : N8N_API_KEY=votre_cle bash import-all.sh${NC}"
    echo ""
    echo "Créer une clé dans n8n :"
    echo "  1. Aller sur $N8N_URL"
    echo "  2. Settings (icône engrenage) > API"
    echo "  3. Create API Key"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Workflows à importer (dans l'ordre)
declare -a WORKFLOWS=(
    "chatbot-deadpool.json"
    "agent-orchestrateur.json"
    "sous-agent-comptable.json"
    "sous-agent-social.json"
    "sous-agent-planning.json"
    "sync-google-calendar.json"
    "email-confirm-rdv.json"
    "email-anniversaire-clients.json"
    "email-hebdo-brevo.json"
    "email-urssaf-brevo.json"
    "relances-clients.json"
    "sms-rappel-rdv-j1.json"
    "sms-rappel-rdv-h1.json"
)

echo -e "${CYAN}Importation des workflows n8n vers $N8N_URL${NC}\n"

SUCCESS=0
FAIL=0

for WF in "${WORKFLOWS[@]}"; do
    FILE="$SCRIPT_DIR/$WF"
    if [ ! -f "$FILE" ]; then
        echo -e "${YELLOW}  ⏭  $WF — fichier introuvable${NC}"
        continue
    fi

    RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X POST "$N8N_URL/api/v1/workflows" \
        -H "X-N8N-API-KEY: $N8N_API_KEY" \
        -H "Content-Type: application/json" \
        -d @"$FILE")

    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    BODY=$(echo "$RESPONSE" | head -1)

    if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "201" ]]; then
        WF_ID=$(echo "$BODY" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo -e "${GREEN}  ✅ $WF${NC} — id: $WF_ID"
        SUCCESS=$((SUCCESS + 1))
    else
        echo -e "  ❌ $WF — HTTP $HTTP_CODE : $BODY"
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo -e "${GREEN}Importation terminée : $SUCCESS OK / $FAIL erreurs${NC}"
echo ""
echo -e "${CYAN}Étape suivante :${NC}"
echo "  - Aller dans n8n > Workflows"
echo "  - Ouvrir chaque workflow et vérifier les credentials (Anthropic, Supabase, Brevo)"
echo "  - Activer les workflows avec le toggle ON"

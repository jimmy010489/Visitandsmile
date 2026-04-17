#!/bin/bash
# ============================================================
# Visit & Smile — Deploy LangGraph Backend to Railway
# Lance depuis : ~/Documents/visit-and-smile/backend/
# ============================================================

set -e

RAILWAY_TOKEN="d78371c1-30e3-44ba-aeeb-d6381655d456"
PROJECT_ID="2a05bd7b-f873-4d98-bc6b-b855a5538af6"
SERVICE_NAME="visit-and-smile-backend"

echo "🚀 Déploiement Visit & Smile Backend → Railway"
echo "================================================"

# 1. Installer Railway CLI si absent
if ! command -v railway &> /dev/null; then
  echo "📦 Installation Railway CLI..."
  # macOS / Linux
  bash <(curl -fsSL https://install.railway.app)
  export PATH="$HOME/.railway/bin:$PATH"
fi

echo "✅ Railway CLI: $(railway --version)"

# 2. Vérifier qu'on est dans le bon dossier
if [ ! -f "api.js" ]; then
  echo "❌ Lance ce script depuis le dossier backend/"
  exit 1
fi

# 3. Deploy
echo ""
echo "📤 Upload du code vers Railway..."
RAILWAY_TOKEN=$RAILWAY_TOKEN railway up \
  --service "$SERVICE_NAME" \
  --detach

echo ""
echo "⚙️  Ajout des variables d'environnement..."
echo "   → Tu dois les entrer manuellement dans Railway Dashboard"
echo "   → https://railway.com/project/$PROJECT_ID"
echo ""
echo "   Variables requises :"
echo "   ANTHROPIC_API_KEY=sk-ant-..."
echo "   SUPABASE_URL=https://zbzicommpdsvkesqzyvb.supabase.co"
echo "   SUPABASE_SERVICE_KEY=eyJ..."
echo "   SUPABASE_DB_URL=postgresql://postgres:[PASSWORD]@db.zbzicommpdsvkesqzyvb.supabase.co:5432/postgres"
echo "   PORT=3004"
echo "   FRONTEND_URL=https://visit-and-smile.vercel.app"
echo ""
echo "🌐 Générer le domaine public :"
echo "   RAILWAY_TOKEN=$RAILWAY_TOKEN railway domain"
echo ""
echo "✅ Déploiement lancé ! Consulte le dashboard pour l'URL finale."
echo "   https://railway.com/project/$PROJECT_ID"

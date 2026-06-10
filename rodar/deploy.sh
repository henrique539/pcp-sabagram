#!/bin/bash

echo "🚀 Deploy PCP Sabagram → Firebase Hosting"
echo "==========================================="

# 1. Verificar se npm está instalado
if ! command -v npm &> /dev/null; then
    echo "❌ npm não encontrado. Instale o Node.js em https://nodejs.org"
    exit 1
fi

# 2. Instalar Firebase CLI se necessário
if ! command -v firebase &> /dev/null; then
    echo "📦 Instalando Firebase CLI..."
    npm install -g firebase-tools
fi

echo "✅ Firebase CLI pronto"

# 3. Login no Firebase
echo ""
echo "🔑 Fazendo login no Firebase (abrirá o browser)..."
firebase login

# 4. Criar pasta de deploy
DEPLOY_DIR="$HOME/pcp-sabagram-deploy"
mkdir -p "$DEPLOY_DIR/public"

# 5. Copiar index.html
INDEX_PATH="$(dirname "$0")/index.html"
if [ ! -f "$INDEX_PATH" ]; then
    echo "❌ index.html não encontrado na mesma pasta deste script."
    echo "   Coloque o index.html na mesma pasta que o deploy.sh"
    exit 1
fi

cp "$INDEX_PATH" "$DEPLOY_DIR/public/index.html"
echo "✅ index.html copiado"

# 6. Criar firebase.json
cat > "$DEPLOY_DIR/firebase.json" << 'FBEOF'
{
  "hosting": {
    "public": "public",
    "ignore": ["firebase.json", "**/.*"],
    "rewrites": [
      { "source": "**", "destination": "/index.html" }
    ],
    "headers": [
      {
        "source": "**",
        "headers": [
          { "key": "Cache-Control", "value": "no-cache, no-store, must-revalidate" }
        ]
      }
    ]
  }
}
FBEOF

# 7. Criar .firebaserc com o projeto
cat > "$DEPLOY_DIR/.firebaserc" << 'RCEOF'
{
  "projects": {
    "default": "pcp-sabagram"
  }
}
RCEOF

echo "✅ Configuração criada"

# 8. Deploy
echo ""
echo "🚀 Fazendo deploy..."
cd "$DEPLOY_DIR"
firebase deploy --only hosting

echo ""
echo "✅ Deploy concluído!"
echo "🌐 Acesse: https://pcp-sabagram.web.app"

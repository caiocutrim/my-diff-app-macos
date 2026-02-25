#!/bin/bash

# Script para buildar o MyDiffApp via terminal
# Uso: ./build.sh [debug|release]

set -e  # Para na primeira falha

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuração padrão
CONFIGURATION="${1:-Debug}"  # Debug ou Release
PROJECT="MyDiffApp.xcodeproj"
SCHEME="MyDiffApp"

echo -e "${BLUE}🔨 Buildando MyDiffApp...${NC}"
echo -e "${YELLOW}Configuração: ${CONFIGURATION}${NC}"
echo ""

# Build do projeto
xcodebuild \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    build \
    | grep -E "^\*\*|error:|warning:" || true

# Verificar se build foi bem-sucedido
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Build bem-sucedido!${NC}"
    echo ""

    # Mostrar localização do app
    BUILD_DIR="${HOME}/Library/Developer/Xcode/DerivedData/MyDiffApp-*/Build/Products/${CONFIGURATION}"
    APP_PATH=$(find ${BUILD_DIR} -name "MyDiffApp.app" -type d 2>/dev/null | head -1)

    if [ -n "${APP_PATH}" ]; then
        echo -e "${BLUE}📦 App criado em:${NC}"
        echo "   ${APP_PATH}"
        echo ""
        echo -e "${YELLOW}Para executar, use:${NC}"
        echo "   ./run.sh"
        echo ""
        echo -e "${YELLOW}Ou abra diretamente:${NC}"
        echo "   open \"${APP_PATH}\""
    fi
else
    echo ""
    echo -e "${RED}❌ Build falhou!${NC}"
    exit 1
fi

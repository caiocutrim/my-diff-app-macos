#!/bin/bash

# Script para executar o MyDiffApp após build
# Uso: ./run.sh [debug|release]

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

CONFIGURATION="${1:-Debug}"
BUILD_DIR="${HOME}/Library/Developer/Xcode/DerivedData/MyDiffApp-*/Build/Products/${CONFIGURATION}"

echo -e "${BLUE}🚀 Executando MyDiffApp...${NC}"
echo ""

# Procurar o app
APP_PATH=$(find ${BUILD_DIR} -name "MyDiffApp.app" -type d 2>/dev/null | head -1)

if [ -z "${APP_PATH}" ]; then
    echo -e "${RED}❌ App não encontrado!${NC}"
    echo "Execute primeiro: ./build.sh"
    exit 1
fi

echo -e "${GREEN}✅ App encontrado:${NC} ${APP_PATH}"
echo ""

# Abrir o app
open "${APP_PATH}"

echo -e "${GREEN}✅ App iniciado!${NC}"

#!/bin/bash

# Script all-in-one: limpa, builda e executa
# Uso: ./dev.sh [debug|release]

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIGURATION="${1:-Debug}"

echo -e "${BLUE}🔄 MyDiffApp - Build & Run${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Limpar build anterior
echo -e "${YELLOW}🧹 Limpando builds anteriores...${NC}"
xcodebuild \
    -project MyDiffApp.xcodeproj \
    -scheme MyDiffApp \
    -configuration "${CONFIGURATION}" \
    clean \
    > /dev/null 2>&1

echo -e "${GREEN}✅ Limpeza concluída${NC}"
echo ""

# Build
echo -e "${YELLOW}🔨 Buildando projeto...${NC}"
./build.sh "${CONFIGURATION}"

# Executar
echo -e "${YELLOW}🚀 Iniciando aplicativo...${NC}"
./run.sh "${CONFIGURATION}"

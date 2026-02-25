# 🚀 Buildar e Executar via Terminal

Você pode buildar e executar o MyDiffApp completamente pelo terminal, sem abrir o Xcode!

## 📋 Scripts Disponíveis

### 1. `./build.sh` - Build do Projeto
Compila o projeto e mostra o resultado.

```bash
# Debug build (padrão)
./build.sh

# Release build (otimizado)
./build.sh release
```

**Output esperado:**
```
🔨 Buildando MyDiffApp...
Configuração: Debug

** BUILD SUCCEEDED **

✅ Build bem-sucedido!

📦 App criado em:
   /Users/ccutrim/Library/Developer/Xcode/DerivedData/MyDiffApp-*/Build/Products/Debug/MyDiffApp.app
```

### 2. `./run.sh` - Executar o App
Abre o app que foi buildado.

```bash
# Executar versão Debug
./run.sh

# Executar versão Release
./run.sh release
```

**Output esperado:**
```
🚀 Executando MyDiffApp...

✅ App encontrado: /path/to/MyDiffApp.app

✅ App iniciado!
```

### 3. `./dev.sh` - Build + Run (Tudo de Uma Vez)
Limpa, builda e executa em um comando só!

```bash
# Debug (padrão)
./dev.sh

# Release
./dev.sh release
```

**Output esperado:**
```
🔄 MyDiffApp - Build & Run
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧹 Limpando builds anteriores...
✅ Limpeza concluída

🔨 Buildando projeto...
** BUILD SUCCEEDED **

🚀 Iniciando aplicativo...
✅ App iniciado!
```

## 🎯 Uso Recomendado

### Durante Desenvolvimento
```bash
# Edite o código, depois:
./dev.sh
```

### Build Rápido (sem limpar)
```bash
./build.sh && ./run.sh
```

### Build de Produção
```bash
./build.sh release
./run.sh release
```

## 🔧 Comandos Diretos (sem scripts)

Se preferir usar xcodebuild diretamente:

### Build Debug
```bash
xcodebuild -project MyDiffApp.xcodeproj -scheme MyDiffApp -configuration Debug build
```

### Build Release
```bash
xcodebuild -project MyDiffApp.xcodeproj -scheme MyDiffApp -configuration Release build
```

### Executar
```bash
open ~/Library/Developer/Xcode/DerivedData/MyDiffApp-*/Build/Products/Debug/MyDiffApp.app
```

### Build + Run em Uma Linha
```bash
xcodebuild -project MyDiffApp.xcodeproj -scheme MyDiffApp build && \
open ~/Library/Developer/Xcode/DerivedData/MyDiffApp-*/Build/Products/Debug/MyDiffApp.app
```

## 📁 Localização dos Builds

Os apps buildados ficam em:

**Debug:**
```
~/Library/Developer/Xcode/DerivedData/MyDiffApp-*/Build/Products/Debug/MyDiffApp.app
```

**Release:**
```
~/Library/Developer/Xcode/DerivedData/MyDiffApp-*/Build/Products/Release/MyDiffApp.app
```

## ⚡️ Atalhos Úteis

### Build Silencioso (sem output)
```bash
./build.sh > /dev/null 2>&1 && echo "✅ Build OK"
```

### Build e Executar em Background
```bash
./build.sh && ./run.sh &
```

### Ver Apenas Erros/Warnings
```bash
xcodebuild -project MyDiffApp.xcodeproj -scheme MyDiffApp build 2>&1 | grep -E "error:|warning:"
```

### Tempo de Build
```bash
time ./build.sh
```

## 🐛 Troubleshooting

### Erro: "Permission denied"
```bash
chmod +x build.sh run.sh dev.sh
```

### Erro: "App não encontrado"
Builde primeiro:
```bash
./build.sh
```

### Limpar Tudo
```bash
xcodebuild -project MyDiffApp.xcodeproj -scheme MyDiffApp clean
rm -rf ~/Library/Developer/Xcode/DerivedData/MyDiffApp-*
```

## 🎨 Customizar Output

Os scripts usam cores ANSI. Para desabilitar:
```bash
NO_COLOR=1 ./dev.sh
```

## 📊 Comparação

| Método | Velocidade | Conveniência | Quando Usar |
|--------|-----------|--------------|-------------|
| `./dev.sh` | 🐢 Lento | ⭐️⭐️⭐️ | Mudanças grandes |
| `./build.sh && ./run.sh` | 🏃 Médio | ⭐️⭐️⭐️ | Uso normal |
| `./run.sh` | 🚀 Rápido | ⭐️⭐️ | Apenas executar |
| xcodebuild direto | 🏃 Médio | ⭐️ | Automação/CI |

## 🎯 Exemplo de Workflow

```bash
# 1. Fazer mudanças no código
vim MyDiffApp/Views/ContentView.swift

# 2. Build e testar
./dev.sh

# 3. Se só mudou código (sem adicionar arquivos)
./build.sh && ./run.sh

# 4. Release build para distribuir
./build.sh release

# 5. Encontrar o .app
find ~/Library/Developer/Xcode/DerivedData -name "MyDiffApp.app" -type d
```

## ✅ Vantagens do Terminal

- ✅ Mais rápido que abrir Xcode
- ✅ Integra com outros scripts
- ✅ Bom para CI/CD
- ✅ Usa menos memória
- ✅ Fácil de automatizar

## 🚀 Quick Start

```bash
# Primeira vez
chmod +x *.sh

# Usar
./dev.sh

# Pronto! 🎉
```

---

**Nunca mais precisa abrir o Xcode para builds rápidos!** 🚀

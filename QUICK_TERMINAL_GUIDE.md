# 🚀 Guia Rápido: Terminal

## TL;DR - Comandos Mais Usados

```bash
# Build + Executar (recomendado)
./dev.sh

# Apenas build
./build.sh

# Apenas executar (depois de buildar)
./run.sh

# Build de produção
./build.sh release
```

## 🎯 Qual Usar?

### `./dev.sh` - Para desenvolvimento ativo
- Limpa builds anteriores
- Builda do zero
- Executa o app
- **Use quando:** fez mudanças no código

### `./build.sh` - Para buildar apenas
- Compila o projeto
- Mostra onde o app foi criado
- **Use quando:** quer apenas verificar se compila

### `./run.sh` - Para executar apenas
- Abre o app já buildado
- **Use quando:** já buildou e quer apenas abrir de novo

## ⚡️ Workflow Recomendado

```bash
# 1. Primeira vez
chmod +x *.sh

# 2. Editar código
vim MyDiffApp/Views/ContentView.swift

# 3. Build e testar
./dev.sh

# 4. Se já buildou antes e quer apenas rodar
./run.sh

# 5. Build de release (produção)
./build.sh release
./run.sh release
```

## 🎨 Output Colorido

Os scripts usam cores para facilitar:
- 🔵 Azul: Informações
- 🟡 Amarelo: Avisos/instruções
- 🟢 Verde: Sucesso
- 🔴 Vermelho: Erros

## 📝 Exemplos Práticos

### Desenvolvimento Rápido
```bash
# Fazer mudanças no código
./dev.sh
# Pronto! App abre automaticamente
```

### Verificar Build sem Executar
```bash
./build.sh
# Apenas compila, não abre o app
```

### Build Silencioso
```bash
./build.sh > /dev/null 2>&1 && echo "✅ OK"
```

### Medir Tempo de Build
```bash
time ./build.sh
```

## 🐛 Problemas?

### "Permission denied"
```bash
chmod +x build.sh run.sh dev.sh
```

### "App não encontrado"
```bash
# Builde primeiro
./build.sh
```

### Limpar tudo
```bash
xcodebuild -project MyDiffApp.xcodeproj -scheme MyDiffApp clean
```

## 🚀 Comparação de Velocidade

| Comando | Tempo ~| O que faz |
|---------|--------|-----------|
| `./run.sh` | < 1s | Apenas abre |
| `./build.sh` | ~10s | Compila |
| `./dev.sh` | ~15s | Limpa + Compila + Abre |
| Xcode | ~30s | Abre Xcode + Compila |

## ✅ Vantagens

- ✅ **10x mais rápido** que abrir o Xcode
- ✅ Usa **menos memória** (não precisa do Xcode aberto)
- ✅ **Scripável** para automação
- ✅ Bom para **CI/CD**
- ✅ **Output limpo** e colorido

---

**Nunca mais precise abrir o Xcode para builds rápidos!** 🎉

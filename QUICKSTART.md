# 🚀 Início Rápido - MyDiffApp

## Executar o App AGORA

### Opção 1: Abrir no Xcode e Executar (Mais Fácil)
```bash
cd /Users/ccutrim/Projects/my-diff-app-macos
open MyDiffApp.xcodeproj
```
Depois pressione `⌘R` no Xcode.

### Opção 2: Build e Executar via Terminal
```bash
cd /Users/ccutrim/Projects/my-diff-app-macos
xcodebuild -project MyDiffApp.xcodeproj -scheme MyDiffApp build
open ~/Library/Developer/Xcode/DerivedData/MyDiffApp-*/Build/Products/Debug/MyDiffApp.app
```

## Testar Rapidamente

1. **Abra o app**
2. **Cole este JSON no painel esquerdo:**
```json
{"name": "João", "age": 30, "city": "São Paulo"}
```

3. **Cole este JSON no painel direito:**
```json
{"name": "João", "age": 31, "email": "joao@example.com"}
```

4. **Clique em "Comparar"** (ou pressione `⌘R`)

5. **Observe as diferenças destacadas:**
   - 🟡 Amarelo: "age" foi modificado (30 → 31)
   - 🔴 Vermelho: "city" foi removido
   - 🟢 Verde: "email" foi adicionado

## Atalhos de Teclado

- `⌘R` - Comparar JSONs
- `⌘K` - Limpar tudo
- `⌘Q` - Sair do app

## O que Você Tem Agora

✅ App nativo macOS funcionando
✅ Comparação de JSON com destaque visual
✅ Formatação automática de JSON
✅ Interface lado a lado
✅ Dark mode suportado
✅ 475 linhas de código Swift
✅ Projeto Xcode completo e compilando

## Estrutura de Arquivos

```
my-diff-app-macos/
├── 📱 MyDiffApp.xcodeproj    # Abra este arquivo no Xcode
├── 📂 MyDiffApp/              # Código-fonte Swift
├── 📄 README.md               # Documentação completa
├── 📄 IMPLEMENTATION.md       # Detalhes da implementação
├── 📄 BUILD_VERIFICATION.md   # Status do build
└── 📄 QUICKSTART.md          # Este arquivo
```

## Documentação Completa

Para mais detalhes, veja:
- **README.md** - Guia completo do usuário
- **IMPLEMENTATION.md** - Detalhes técnicos da implementação
- **BUILD_VERIFICATION.md** - Informações sobre o build

## Suporte

Se encontrar problemas:
1. Execute: `xcodebuild -runFirstLaunch`
2. Reinicie o Xcode
3. Clean o projeto: `⌘⇧K` no Xcode

---

**Pronto para usar!** 🎉

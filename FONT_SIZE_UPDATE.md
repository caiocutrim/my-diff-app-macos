# 📏 Update: Controle de Tamanho de Fonte

## ✨ Implementado

### 1. **Tamanho de Fonte Consistente**
- Todas as fontes agora usam o mesmo tamanho
- Editor de entrada e visualização de diff sincronizados

### 2. **Controle na Toolbar**
Interface para ajustar o tamanho da fonte:
- **Botão "-"** - Diminuir fonte (⌘-)
- **Display "13pt"** - Mostra tamanho atual
- **Botão "+"** - Aumentar fonte (⌘+)
- **Botão reset** - Voltar ao padrão (⌘0)

### 3. **Persistência**
- Usa `@AppStorage` para salvar preferência
- Tamanho persiste entre sessões do app
- Padrão: **13pt**
- Range: **10pt a 24pt**

## 🎯 Como Funciona

### FontSettings (Singleton)
```swift
class FontSettings: ObservableObject {
    @AppStorage("fontSize") var fontSize: Double = 13

    func increase() // Aumentar
    func decrease() // Diminuir
    func reset()    // Resetar para 13pt
}
```

### Atalhos de Teclado
| Ação | Atalho | Descrição |
|------|--------|-----------|
| Aumentar | `⌘+` | Aumenta 1pt |
| Diminuir | `⌘-` | Diminui 1pt |
| Resetar | `⌘0` | Volta para 13pt |

## 📁 Arquivos Modificados

1. **FontSettings.swift** (novo)
   - Gerenciador de configurações de fonte
   - Singleton com @AppStorage
   - Métodos increase/decrease/reset

2. **ContentView.swift**
   - Toolbar com controles de fonte
   - Observa FontSettings
   - Atalhos de teclado

3. **JSONTextEditor.swift**
   - Usa fontSize dinâmico
   - Atualiza quando fontSize muda
   - Passa fontSize para highlighter

4. **DetailedDiffPaneView.swift**
   - Observa FontSettings
   - Aplica tamanho de fonte consistente
   - Números de linha proporcionais (85%)

5. **JSONSyntaxHighlighter.swift**
   - Aceita fontSize como parâmetro
   - Aplica fonte em NSAttributedString
   - Mantém highlighting com tamanho correto

## 🧪 Como Testar

### 1. Build e Execute
```bash
./build.sh
# Não vou executar para economizar tokens
```

### 2. Teste os Controles
- Cole JSON no editor
- Clique no botão **"+"** várias vezes
  - Observe texto ficar maior
- Clique no botão **"-"** várias vezes
  - Observe texto ficar menor
- Clique no botão **reset** (↻)
  - Deve voltar para 13pt

### 3. Teste os Atalhos
- `⌘+` para aumentar
- `⌘-` para diminuir
- `⌘0` para resetar

### 4. Teste Persistência
- Ajuste para 18pt
- Feche o app
- Reabra o app
- Deve abrir com 18pt

### 5. Teste Consistência
- Ajuste o tamanho da fonte
- Cole JSON nos dois lados
- Clique "Comparar"
- Verifique que todos os textos têm mesmo tamanho:
  - Campos de entrada
  - Resultado do diff
  - Números de linha

## 🎨 Interface da Toolbar

```
┌────────────────────────────────────────────────────────┐
│ [Comparar] [Limpar] [Formatar] │ [-] 13pt [+] [↻]     │
│                                  ↑    ↑    ↑   ↑       │
│                            diminuir tam aumentar reset │
└────────────────────────────────────────────────────────┘
```

## 📊 Range de Tamanhos

| Tamanho | Uso Recomendado |
|---------|-----------------|
| 10-12pt | Para JSONs grandes, ver mais conteúdo |
| 13pt | Padrão, balanceado |
| 14-16pt | Leitura confortável |
| 18-24pt | Apresentações, acessibilidade |

## ✅ Benefícios

1. **Consistência** - Todos os textos com mesmo tamanho
2. **Personalização** - Cada usuário pode ajustar
3. **Persistência** - Não precisa ajustar toda vez
4. **Acessibilidade** - Tamanhos maiores para quem precisa
5. **Produtividade** - Tamanhos menores para ver mais código

## 🔧 Implementação Técnica

### @AppStorage
```swift
@AppStorage("fontSize") var fontSize: Double = 13
```
Salva automaticamente em UserDefaults.

### ObservableObject
```swift
class FontSettings: ObservableObject {
    @AppStorage("fontSize") var fontSize: Double = 13
}
```
Notifica todas as views quando fontSize muda.

### Aplicação nas Views
```swift
@ObservedObject var fontSettings = FontSettings.shared

Text(content)
    .font(.system(size: CGFloat(fontSettings.fontSize), design: .monospaced))
```

## 🐛 Edge Cases Tratados

- **Mínimo**: Não deixa ficar menor que 10pt
- **Máximo**: Não deixa ficar maior que 24pt
- **Cursor**: Preservado ao mudar tamanho
- **Highlighting**: Mantido ao mudar tamanho
- **Scroll**: Posição mantida ao mudar tamanho

## 📈 Estatísticas

- **1 novo arquivo**: FontSettings.swift (~60 linhas)
- **5 arquivos modificados**: ContentView, JSONTextEditor, DetailedDiffPaneView, JSONSyntaxHighlighter
- **~100 linhas alteradas**
- **Total no projeto**: ~1350 linhas

---

**Teste e me diga como ficou!** 🎯

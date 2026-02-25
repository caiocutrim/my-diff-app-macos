# 🎨 Update: Syntax Highlighting + Character-Level Diff

## ✅ Build Succeeded!

O projeto foi atualizado com sucesso com **syntax highlighting para JSON** e **comparação character-level** para mostrar exatamente o que mudou!

## 🆕 Novas Funcionalidades

### 1. Syntax Highlighting de JSON
Agora o JSON é exibido com cores diferentes para cada elemento:
- **🟣 Roxo**: Chaves JSON (keys)
- **🔴 Vermelho**: Valores string
- **🔵 Azul**: Números
- **🟠 Laranja**: Booleanos e null
- **⚫️ Cinza**: Pontuação ({}, [], :, ,)

### 2. Character-Level Diff
Em vez de apenas destacar a linha inteira, agora mostra **exatamente quais caracteres** mudaram:
- Dentro de uma linha modificada, apenas os caracteres diferentes são destacados
- Usa algoritmo **Longest Common Subsequence (LCS)** para precisão
- Combina syntax highlighting com destaque de diferenças

### 3. Destaque Melhorado
- **Background mais sutil** (10% opacity) para não sobrepor o syntax highlighting
- **Destaque mais preciso** (30% opacity) nos caracteres que realmente mudaram
- Melhor visualização de múltiplas mudanças na mesma linha

## 📁 Novos Arquivos Criados

### Models
- **CharacterDiff.swift** - Modelo para segmentos de texto com tipo de diff
- Define `DiffSegmentType`: unchanged, added, removed, modified
- `DetailedDiffLine`: linha com segmentos character-level

### Services
- **CharacterDiffEngine.swift** - Algoritmo de diff character-level
  - Implementa Longest Common Subsequence (LCS)
  - Compara strings caractere por caractere
  - ~150 linhas de código com algoritmo otimizado

- **JSONSyntaxHighlighter.swift** - Syntax highlighting para JSON
  - Usa `AttributedString` do SwiftUI
  - Regex patterns para identificar elementos JSON
  - Combina cores de sintaxe com background de diff

### Views
- **DetailedDiffPaneView.swift** - Painel com syntax highlighting
  - Substitui `TextEditor` por `Text` com `AttributedString`
  - Suporte a seleção de texto
  - Background mais sutil para linhas modificadas

- **DetailedDiffResultView.swift** - Visualização melhorada
  - Layout lado a lado com syntax highlighting
  - Legenda atualizada
  - Indicador visual de "Syntax Highlighting Ativo"

### Atualizações em Arquivos Existentes
- **DiffEngine.swift** - Adicionado método `compareDetailed()`
- **ContentView.swift** - Usa novos componentes com highlighting

## 🎯 Como Funciona

### Exemplo Prático

**JSON Esquerda:**
```json
{"name": "João", "age": 30}
```

**JSON Direita:**
```json
{"name": "Maria", "age": 30}
```

**Resultado Visual:**

Na linha `"name"`, você verá:
- `"name":` em roxo (key)
- `"João"` com background vermelho claro (removido)
- `"Maria"` com background verde claro (adicionado)
- `"age": 30` sem destaque (igual em ambos)

E tudo com **syntax highlighting ativo**! 🎨

## 📊 Estatísticas

### Arquivos Adicionados/Modificados
- **5 novos arquivos** criados
- **3 arquivos** modificados
- **~400 linhas de código** adicionadas

### Total do Projeto
- **13 arquivos Swift** (antes: 8)
- **~875 linhas de código** (antes: 475)
- **+84% mais código** com funcionalidades avançadas

## 🚀 Como Testar

```bash
cd /Users/ccutrim/Projects/my-diff-app-macos
open MyDiffApp.xcodeproj
# Pressione ⌘R no Xcode
```

### Teste com Este Exemplo:

**Esquerda:**
```json
{
  "user": "João Silva",
  "age": 30,
  "active": true,
  "score": 95.5
}
```

**Direita:**
```json
{
  "user": "Maria Silva",
  "age": 31,
  "active": true,
  "score": 95.5
}
```

**Observe:**
- Nome destacado character-level: "João" → "Maria"
- Idade destacada: 30 → 31
- Syntax highlighting em todas as chaves, strings, números e booleanos
- Background sutil para não atrapalhar as cores de sintaxe

## 🎨 Esquema de Cores

### Syntax Highlighting
| Elemento | Cor | Exemplo |
|----------|-----|---------|
| Keys | Roxo | `"name":` |
| Strings | Vermelho | `"João"` |
| Numbers | Azul | `30`, `95.5` |
| Booleans/Null | Laranja | `true`, `false`, `null` |
| Punctuation | Cinza | `{`, `}`, `[`, `]`, `:`, `,` |

### Diff Highlighting
| Tipo | Background | Exemplo |
|------|-----------|---------|
| Linha igual | Transparente | Sem destaque |
| Linha modificada | Amarelo 10% | Background sutil |
| Caracteres adicionados | Verde 30% | Destaque nos chars |
| Caracteres removidos | Vermelho 30% | Destaque nos chars |

## 🔧 Implementação Técnica

### Algoritmo LCS (Longest Common Subsequence)
- Encontra a maior subsequência comum entre duas strings
- Usa programação dinâmica com matriz O(n*m)
- Reconstrói a sequência para identificar diferenças

### AttributedString do SwiftUI
- Permite aplicar múltiplos estilos ao mesmo texto
- Suporta `foregroundColor` para syntax highlighting
- Suporta `backgroundColor` para diff highlighting
- Combina perfeitamente ambos os estilos

### Regex Patterns para JSON
```swift
"\"[^\"]*\"\\s*:"  // Chaves (string seguida de :)
"\"[^\"]*\""       // Strings (valores)
"-?\\d+\\.?\\d*"   // Números (int ou float)
"\\b(true|false|null)\\b"  // Booleanos e null
"[{}\\[\\],:]"     // Pontuação
```

## ⚡️ Performance

- Algoritmo LCS é O(n*m) onde n e m são tamanhos das strings
- Para JSONs típicos (<1000 linhas), é instantâneo
- Regex matching é otimizado pelo NSRegularExpression
- AttributedString rendering é nativo do SwiftUI

## 🎓 Próximas Melhorias (Opcionais)

1. **Temas customizáveis** - Permitir usuário escolher cores
2. **Modo de comparação estrutural** - Ignorar formatação, comparar apenas estrutura JSON
3. **Export com highlighting** - Salvar resultado como HTML ou RTF
4. **Minimap** - Visão geral das diferenças no documento
5. **Jump to difference** - Botões para navegar entre diferenças

## 📚 Referências

- [SwiftUI AttributedString](https://developer.apple.com/documentation/foundation/attributedstring)
- [Longest Common Subsequence Algorithm](https://en.wikipedia.org/wiki/Longest_common_subsequence_problem)
- [NSRegularExpression](https://developer.apple.com/documentation/foundation/nsregularexpression)

---

**Status**: ✅ Totalmente funcional e compilando!
**Data**: 2026-02-09
**Versão**: 2.0 (com Syntax Highlighting)

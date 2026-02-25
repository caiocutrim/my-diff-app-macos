# MyDiffApp - Diff Checker para JSON (macOS)

Um aplicativo nativo macOS para comparação de arquivos JSON, com formatação automática e visualização clara das diferenças.

## Características

- ✅ Interface nativa macOS com SwiftUI
- ✅ Comparação lado a lado de JSONs
- ✅ Formatação automática de JSON
- ✅ Destaque visual de diferenças:
  - 🟢 Verde: linhas adicionadas
  - 🔴 Vermelho: linhas removidas
  - 🟡 Amarelo: linhas modificadas
- ✅ Suporte para dark mode
- ✅ Atalhos de teclado (⌘R para comparar, ⌘K para limpar)

## Requisitos

- macOS 13.0 (Ventura) ou superior
- Xcode 15.0 ou superior

## Instalação e Execução

### Opção 1: Abrir no Xcode

```bash
open MyDiffApp.xcodeproj
```

Depois pressione `⌘R` para compilar e executar.

### Opção 2: Build via linha de comando

```bash
# Build do projeto
xcodebuild -project MyDiffApp.xcodeproj -scheme MyDiffApp -configuration Release build

# Executar o app
open build/Release/MyDiffApp.app
```

## Como Usar

1. **Cole seus JSONs**: Cole o JSON original no painel esquerdo e o JSON para comparar no painel direito
2. **Clique em "Comparar"** (ou pressione `⌘R`): O app irá formatar automaticamente ambos os JSONs e mostrar as diferenças
3. **Visualize as diferenças**: Linhas diferentes serão destacadas com cores
4. **Limpar**: Clique em "Limpar" (ou pressione `⌘K`) para resetar e começar uma nova comparação

## Arquitetura do Projeto

```
MyDiffApp/
├── MyDiffApp.swift          # Entry point do app
├── Views/
│   ├── ContentView.swift    # Interface principal
│   ├── DiffPaneView.swift   # Componente de painel individual
│   └── DiffResultView.swift # Visualização do resultado do diff
├── Models/
│   ├── DiffLine.swift       # Modelo de linha do diff
│   └── DiffResult.swift     # Resultado completo do diff
└── Services/
    ├── JSONFormatter.swift  # Formatação e validação de JSON
    └── DiffEngine.swift     # Algoritmo de comparação
```

## Atalhos de Teclado

- `⌘R` - Comparar JSONs
- `⌘K` - Limpar campos

## Exemplo de Uso

**JSON Original (Esquerda):**
```json
{
  "name": "João",
  "age": 30,
  "city": "São Paulo"
}
```

**JSON Comparado (Direita):**
```json
{
  "name": "João",
  "age": 31,
  "city": "São Paulo",
  "email": "joao@example.com"
}
```

**Resultado:**
- `"name": "João"` - sem destaque (igual)
- `"age": 30` vs `"age": 31` - amarelo (modificado)
- `"city": "São Paulo"` - sem destaque (igual)
- `"email": "joao@example.com"` - verde (adicionado)

## Limitações Conhecidas (v1.0)

- Comparação linha por linha (não destaca diferenças dentro da mesma linha)
- Performance pode ser afetada com arquivos muito grandes (+10k linhas)
- Apenas suporte para JSON (conforme especificação inicial)

## Desenvolvimento

Para contribuir ou modificar o projeto:

1. Clone o repositório
2. Abra `MyDiffApp.xcodeproj` no Xcode
3. Faça suas modificações
4. Execute os testes (se disponíveis)
5. Build e teste o app

## Licença

Este projeto foi criado como ferramenta de desenvolvimento. Use conforme necessário.

## Créditos

Desenvolvido com SwiftUI para macOS.

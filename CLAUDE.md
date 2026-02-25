# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MyDiffApp is a native macOS app (SwiftUI) for comparing JSON files side-by-side with character-level diff highlighting and Dracula theme syntax coloring. No external dependencies — uses only Foundation and AppKit/SwiftUI.

**Platform**: macOS 13.0+ (Ventura) | **Language**: Swift 5.0

## Development Commands

```bash
# Build (debug by default, pass "release" for release build)
./build.sh [debug|release]

# Clean + build + run in one step
./dev.sh [debug|release]

# Run after a successful build
./run.sh [debug|release]

# Or open in Xcode directly
open MyDiffApp.xcodeproj    # then ⌘R to build & run, ⌘U for tests

# CLI build without scripts
xcodebuild -project MyDiffApp.xcodeproj -scheme MyDiffApp build
```

Build artifacts go to `~/Library/Developer/Xcode/DerivedData/MyDiffApp-*/Build/Products/`.

## Architecture

### Data Flow

1. User pastes JSON into two `JSONTextEditor` panes (NSTextView wrapped via `NSViewRepresentable` with live syntax highlighting)
2. On compare (⌘R), `ContentView` formats both inputs through `JSONFormatter` (validates + pretty-prints with sorted keys)
3. `DiffEngine.compareDetailed()` runs line-by-line comparison producing `[DetailedDiffLine]`
4. For each modified line, `CharacterDiffEngine` runs LCS-based character-level diff producing `[CharacterDiff]` segments
5. `DetailedDiffResultView` renders two `DetailedDiffPaneView` panels in an `HSplitView` with synchronized scroll
6. `JSONSyntaxHighlighter` applies Dracula-themed coloring to each segment (keys, strings, numbers, booleans, punctuation)

### Key Layers

- **Services/**: All comparison and formatting logic. `DiffEngine` (line-level), `CharacterDiffEngine` (character-level via LCS algorithm), `JSONFormatter` (validation/formatting via `JSONSerialization`), `JSONSyntaxHighlighter` (regex-based syntax coloring for both `NSAttributedString` and SwiftUI `AttributedString`)
- **Models/**: `DiffLine`/`DiffResult` (line-level diff), `CharacterDiff`/`DetailedDiffLine` (character-level diff). Types: `DiffLineType` (equal/added/removed/modified), `DiffSegmentType` (unchanged/added/removed/modified)
- **Views/**: `ContentView` (state management + toolbar), `JSONTextEditor` (NSViewRepresentable wrapping NSTextView), `DetailedDiffResultView`/`DetailedDiffPaneView` (diff output), `DiffResultView`/`DiffPaneView` (legacy line-level views)
- **Utilities/**: `DraculaTheme` (color constants + `Color(hex:)` extension), `FontSettings` (ObservableObject singleton with `@AppStorage` persistence, range 10-24pt)

### Design Decisions

- `JSONTextEditor` bridges AppKit's `NSTextView` into SwiftUI via `NSViewRepresentable` because SwiftUI's `TextEditor` lacks attributed string support needed for live syntax highlighting
- Character diff uses a classic LCS (Longest Common Subsequence) DP algorithm — O(m*n) complexity, fine for formatted JSON lines but not suitable for very long single lines
- `JSONSyntaxHighlighter` has dual APIs: `NSAttributedString` for the input editors (AppKit) and `AttributedString` for the diff output views (SwiftUI)
- Theme colors are hardcoded in `DraculaTheme` as static constants (no runtime theme switching yet)
- Font size persisted via `@AppStorage("fontSize")` — shared through `FontSettings.shared` singleton

### Keyboard Shortcuts

⌘R compare, ⌘K clear, ⌘+ increase font, ⌘- decrease font, ⌘0 reset font

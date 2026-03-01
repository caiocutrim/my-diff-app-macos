# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MyDiffApp is a native macOS app (SwiftUI) for comparing JSON files side-by-side with character-level diff highlighting and GitHub-dark syntax coloring. No external dependencies — uses only Foundation and AppKit/SwiftUI.

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

1. User pastes JSON into two `JSONTextEditor` panes (NSTextView wrapped via `NSViewRepresentable` with live syntax highlighting and line number ruler)
2. On compare (⌘R), `ContentView` formats both inputs through `JSONFormatter` (validates + pretty-prints with sorted keys)
3. `JSONStructureAnalyzer` checks structural compatibility — if divergence is detected (< 20% key overlap or type mismatch), a native `NSAlert` asks the user to confirm before proceeding
4. `DiffEngine.compareDetailed()` runs LCS-based line-by-line comparison producing `[DetailedDiffLine]`
5. For each modified line, `CharacterDiffEngine` runs LCS-based character-level diff producing `[CharacterDiff]` segments
6. `DetailedDiffResultView` renders two `DetailedDiffPaneView` panels in an `HSplitView` with synchronized scroll
7. `JSONSyntaxHighlighter` applies GitHub-dark syntax coloring to each segment (keys, strings, numbers, booleans, punctuation)
8. `DiffSummaryView` shows a collapsible summary panel — clicking any item scrolls both panes to the corresponding line and triggers a flash animation

### Key Layers

- **Services/**: All comparison and formatting logic.
  - `DiffEngine` — LCS line-level diff + modified-line pairing + summary extraction
  - `CharacterDiffEngine` — LCS character-level diff
  - `JSONFormatter` — validation/formatting via `JSONSerialization`; extracts error line/column from Foundation errors
  - `JSONSyntaxHighlighter` — regex-based syntax coloring for `NSAttributedString` (editors) and `AttributedString` (diff views)
  - `JSONStructureAnalyzer` — Jaccard similarity on key paths (depth 2); warns on type mismatch or < 20% overlap

- **Models/**:
  - `DiffLine` / `DiffResult` — legacy line-level diff types
  - `CharacterDiff` / `DetailedDiffLine` — character-level diff with separate `leftLineNumber`/`rightLineNumber` (nil for added/removed sides)
  - `DiffSummary` — `DiffSummaryItem` with `lineID: UUID` linking each summary entry to its `DetailedDiffLine`

- **Views/**:
  - `ContentView` — state management, toolbars (edit/diff modes), inline error banners, font controls
  - `JSONTextEditor` — `NSViewRepresentable` wrapping `NSTextView` with live syntax highlighting, `LineNumberRulerView`, and error-line red background
  - `DetailedDiffResultView` / `DetailedDiffPaneView` — diff output with `HighlightRequest`-based flash animation and synchronized scroll
  - `DiffSummaryView` / `SummaryItemRow` — collapsible summary panel with click-to-scroll and hover effects

- **Utilities/**:
  - `AppTheme` — GitHub-dark color palette as static constants + `Color(hex:)` extension
  - `FontSettings` — `ObservableObject` singleton with `@AppStorage` persistence, range 10–24pt

### Design Decisions

- `JSONTextEditor` bridges AppKit's `NSTextView` into SwiftUI via `NSViewRepresentable` — SwiftUI's `TextEditor` lacks attributed string support needed for live syntax highlighting
- `LineNumberRulerView` subclasses `NSRulerView` and attaches to the `NSScrollView`; redraws via `NSNotificationCenter` on text change and scroll
- LCS is used at two levels: line-level in `DiffEngine` (avoids brace/bracket pollution when fields are inserted) and character-level in `CharacterDiffEngine`
- Adjacent `(removed, added)` pairs with the same JSON key are merged as a single `.modified` row with character-level highlighting
- Inline character highlights (segment backgrounds) are only applied to `.modified` lines — `.added`/`.removed` lines use line-level background only, preventing over-saturation
- `HighlightRequest` carries a `nonce: UUID` so `.onChange` always fires even when the same summary item is clicked twice
- `JSONFormatter` parses character offset from `NSDebugDescriptionErrorKey` ("around character N"); falls back to last non-empty line for end-of-file errors
- `JSONStructureAnalyzer` uses `NSAlert` with `NSImage.cautionName` (native macOS warning triangle) — not SwiftUI `.alert` which doesn't support custom icons
- Theme colors hardcoded in `AppTheme` as static constants (no runtime theme switching)
- Font size persisted via `@AppStorage("fontSize")` shared through `FontSettings.shared` singleton

### Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `⌘R` | Compare |
| `⌘K` | Clear both panes |
| `⌘+` / `⌘−` | Increase / decrease font size |
| `⌘0` | Reset font size |

### Adding New Source Files

When creating a new `.swift` file, register it in `MyDiffApp.xcodeproj/project.pbxproj` manually:
1. Add a `PBXBuildFile` entry (`A1000000100000000000XXXX`)
2. Add a `PBXFileReference` entry (`A2000000100000000000XXXX`)
3. Add the file reference to the appropriate group's `children` array
4. Add the build file to the `Sources` build phase

Use the next sequential ID after the last `A[12]0000001000000000000XXX` entry in the file.

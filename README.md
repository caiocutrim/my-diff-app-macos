# MyDiffApp

Native macOS app for comparing JSON side-by-side with character-level diff highlighting.

![macOS](https://img.shields.io/badge/macOS-13.0+-000000?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.0-F05138?logo=swift)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## Install (pre-built binary)

> Requires macOS 13.0 Ventura or later · Apple Silicon

**1. Download the latest release**

Go to [Releases](https://github.com/caiocutrim/my-diff-app-macos/releases) and download `MyDiffApp-v0.1.0-macos.zip`.

**2. Move to Applications**

```bash
unzip MyDiffApp-v0.1.0-macos.zip
mv MyDiffApp.app /Applications/
```

**3. First launch — bypass Gatekeeper**

The app isn't notarized yet, so macOS will block it on the first open.
Two ways to get past it:

Option A — right-click in Finder:
```
Right-click MyDiffApp.app → Open → Open
```

Option B — terminal one-liner:
```bash
xattr -cr /Applications/MyDiffApp.app && open /Applications/MyDiffApp.app
```

That's it. You won't need to do this again.

---

## Build from source

```bash
git clone https://github.com/caiocutrim/my-diff-app-macos.git
cd my-diff-app-macos

# Build and run
./dev.sh

# Or open in Xcode
open MyDiffApp.xcodeproj   # then ⌘R
```

Requirements: Xcode 15+ with Command Line Tools.

---

## Usage

1. Paste the original JSON in the **left pane**
2. Paste the JSON to compare in the **right pane**
3. Press **⌘R** to compare

Differences are highlighted inline:

| Color | Meaning |
|---|---|
| 🟢 Green | Line added on the right |
| 🔴 Red | Line removed from the left |
| 🟡 Yellow | Line modified — changed characters highlighted |

The **summary panel** at the bottom lists every changed field with old → new values.

**Keyboard shortcuts**

| Shortcut | Action |
|---|---|
| `⌘R` | Compare |
| `⌘K` | Clear both panes |
| `⌘+` / `⌘−` | Increase / decrease font size |
| `⌘0` | Reset font size |

---

## How the diff works

The engine uses **LCS (Longest Common Subsequence)** on lines — the same algorithm behind `git diff`. Equal lines are matched by content regardless of position, so inserting a new field doesn't cascade spurious changes on everything below it.

For lines that changed, a second LCS pass runs on characters to highlight exactly which parts of the value were modified.

---

## Project structure

```
MyDiffApp/
├── Services/
│   ├── DiffEngine.swift          # LCS line diff + modified pairing
│   ├── CharacterDiffEngine.swift # LCS character diff
│   ├── JSONFormatter.swift       # Validate + pretty-print
│   └── JSONSyntaxHighlighter.swift
├── Views/
│   ├── ContentView.swift         # Toolbar, state, keyboard shortcuts
│   ├── DetailedDiffResultView.swift
│   ├── DetailedDiffPaneView.swift # Line rows with gutter + border
│   └── DiffSummaryView.swift     # Bottom summary panel
├── Models/
│   ├── CharacterDiff.swift       # DetailedDiffLine, DiffSegmentType
│   ├── DiffLine.swift
│   └── DiffSummary.swift
└── Utilities/
    ├── AppTheme.swift            # GitHub-dark color palette
    └── FontSettings.swift        # @AppStorage font size persistence
```

---

## License

MIT

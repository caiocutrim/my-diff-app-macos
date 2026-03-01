//
//  JSONTextEditor.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI
import AppKit

struct JSONTextEditor: View {
    @Binding var text: String
    let placeholder: String
    var errorLocation: JSONParseLocation? = nil
    @ObservedObject var fontSettings = FontSettings.shared

    var body: some View {
        JSONTextEditorRepresentable(
            text: $text,
            placeholder: placeholder,
            fontSize: fontSettings.fontSize,
            errorLocation: errorLocation
        )
    }
}

struct JSONTextEditorRepresentable: NSViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let fontSize: Double
    var errorLocation: JSONParseLocation?

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.allowsUndo = true
        textView.font = NSFont.monospacedSystemFont(ofSize: CGFloat(fontSize), weight: .regular)
        textView.textColor = NSColor(AppTheme.text)
        textView.backgroundColor = NSColor(AppTheme.background)
        textView.insertionPointColor = NSColor(AppTheme.accent)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.textContainerInset = NSSize(width: 8, height: 8)

        // Line number ruler
        let ruler = LineNumberRulerView(textView: textView, fontSize: CGFloat(fontSize))
        scrollView.verticalRulerView = ruler
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! NSTextView

        // Sync font size
        if let currentFont = textView.font, currentFont.pointSize != CGFloat(fontSize) {
            textView.font = NSFont.monospacedSystemFont(ofSize: CGFloat(fontSize), weight: .regular)
            (scrollView.verticalRulerView as? LineNumberRulerView)?.update(fontSize: CGFloat(fontSize))
        }

        let textChanged  = textView.string != text
        let errorChanged = context.coordinator.lastErrorLine != errorLocation?.line

        if textChanged || errorChanged {
            context.coordinator.lastErrorLine = errorLocation?.line
            let selectedRange = textView.selectedRange()

            let highlighted = JSONSyntaxHighlighter.highlightJSON(
                text, theme: .material, fontSize: CGFloat(fontSize)
            )

            if let loc = errorLocation, let range = lineNSRange(in: text, line: loc.line) {
                let mutable = NSMutableAttributedString(attributedString: highlighted)
                mutable.addAttribute(
                    .backgroundColor,
                    value: NSColor(red: 0.973, green: 0.318, blue: 0.286, alpha: 0.35),
                    range: range
                )
                textView.textStorage?.setAttributedString(mutable)
            } else {
                textView.textStorage?.setAttributedString(highlighted)
            }

            if selectedRange.location <= textView.string.count {
                textView.setSelectedRange(selectedRange)
            }
        }
    }

    // MARK: - Helpers

    private func lineNSRange(in text: String, line targetLine: Int) -> NSRange? {
        guard targetLine >= 1 else { return nil }
        let nsText = text as NSString
        var offset  = 0
        var lineNum = 1

        while offset <= nsText.length {
            var lineStart = 0, lineEnd = 0, contentsEnd = 0
            nsText.getLineStart(&lineStart, end: &lineEnd, contentsEnd: &contentsEnd,
                                for: NSRange(location: offset, length: 0))
            if lineNum == targetLine {
                return NSRange(location: lineStart, length: contentsEnd - lineStart)
            }
            lineNum += 1
            if lineEnd == offset { break }
            offset = lineEnd
        }
        return nil
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: JSONTextEditorRepresentable
        var lastErrorLine: Int? = nil

        init(_ parent: JSONTextEditorRepresentable) { self.parent = parent }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string

            let selectedRange = textView.selectedRange()
            let attributed = JSONSyntaxHighlighter.highlightJSON(
                textView.string, theme: .material, fontSize: CGFloat(parent.fontSize)
            )
            textView.textStorage?.setAttributedString(attributed)
            if selectedRange.location <= textView.string.count {
                textView.setSelectedRange(selectedRange)
            }
        }
    }
}

// MARK: - Line Number Ruler

final class LineNumberRulerView: NSRulerView {

    private weak var textView: NSTextView?
    private var fontSize: CGFloat

    // Colors matching AppTheme (NSColor equivalents)
    private let bgColor     = NSColor(red: 0.075, green: 0.090, blue: 0.110, alpha: 1) // slightly darker than background
    private let borderColor = NSColor(red: 0.188, green: 0.212, blue: 0.247, alpha: 1) // #30363d
    private let lineNumColor = NSColor(red: 0.282, green: 0.322, blue: 0.376, alpha: 1) // #484f58

    init(textView: NSTextView, fontSize: CGFloat = 13) {
        self.textView = textView
        self.fontSize = fontSize
        super.init(scrollView: textView.enclosingScrollView, orientation: .verticalRuler)
        ruleThickness = 44

        NotificationCenter.default.addObserver(
            self, selector: #selector(refresh),
            name: NSText.didChangeNotification, object: textView
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(refresh),
            name: NSView.boundsDidChangeNotification,
            object: textView.enclosingScrollView?.contentView
        )
    }

    required init(coder: NSCoder) { fatalError() }
    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func refresh() { needsDisplay = true }

    func update(fontSize: CGFloat) {
        self.fontSize = fontSize
        needsDisplay = true
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else { return }

        // Background
        bgColor.setFill()
        bounds.fill()

        // Right-edge separator
        borderColor.setStroke()
        let sep = NSBezierPath()
        sep.move(to: NSPoint(x: bounds.maxX - 0.5, y: rect.minY))
        sep.line(to: NSPoint(x: bounds.maxX - 0.5, y: rect.maxY))
        sep.lineWidth = 1
        sep.stroke()

        let rulerFontSize = max(fontSize * 0.82, 9)
        let attrs: [NSAttributedString.Key: Any] = [
            .font:            NSFont.monospacedSystemFont(ofSize: rulerFontSize, weight: .regular),
            .foregroundColor: lineNumColor
        ]

        let nsString    = textView.string as NSString
        let origin      = textView.textContainerOrigin  // (inset.width, inset.height)
        let visible     = textView.visibleRect
        let glyphCount  = layoutManager.numberOfGlyphs

        guard glyphCount > 0 else {
            drawLineNumber(1, y: origin.y - visible.minY, height: fontSize + 4, attrs: attrs)
            return
        }

        var lineNumber = 1

        layoutManager.enumerateLineFragments(
            forGlyphRange: NSRange(location: 0, length: glyphCount)
        ) { [weak self] lineRect, _, _, glyphRange, _ in
            guard let self else { return }

            let charRange     = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            let isLogicalLine = charRange.location == 0
                             || nsString.character(at: charRange.location - 1) == 10 // '\n'

            defer { if isLogicalLine { lineNumber += 1 } }
            guard isLogicalLine else { return }

            // Convert text-container coords → ruler coords
            let lineY = lineRect.minY + origin.y - visible.minY

            // Only draw visible rows (small margin for safety)
            guard lineY + lineRect.height >= -lineRect.height,
                  lineY <= self.bounds.height + lineRect.height else { return }

            self.drawLineNumber(lineNumber, y: lineY, height: lineRect.height, attrs: attrs)
        }

        // Extra blank line when text ends with '\n' (or is empty)
        if textView.string.hasSuffix("\n") || textView.string.isEmpty {
            let lastGlyph = glyphCount - 1
            let lastRect  = layoutManager.lineFragmentRect(forGlyphAt: lastGlyph, effectiveRange: nil)
            let lineY     = lastRect.maxY + origin.y - visible.minY
            let h         = lastRect.height > 0 ? lastRect.height : rulerFontSize + 4
            if lineY >= -h && lineY <= bounds.height + h {
                drawLineNumber(lineNumber, y: lineY, height: h, attrs: attrs)
            }
        }
    }

    private func drawLineNumber(_ n: Int, y: CGFloat, height: CGFloat, attrs: [NSAttributedString.Key: Any]) {
        let label = "\(n)" as NSString
        let sz    = label.size(withAttributes: attrs)
        let drawX = ruleThickness - 10 - sz.width
        let drawY = y + (height - sz.height) / 2
        label.draw(at: NSPoint(x: drawX, y: drawY), withAttributes: attrs)
    }
}

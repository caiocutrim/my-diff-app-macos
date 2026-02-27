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
    @ObservedObject var fontSettings = FontSettings.shared

    var body: some View {
        JSONTextEditorRepresentable(text: $text, placeholder: placeholder, fontSize: fontSettings.fontSize)
    }
}

struct JSONTextEditorRepresentable: NSViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let fontSize: Double

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

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! NSTextView

        if let currentFont = textView.font, currentFont.pointSize != CGFloat(fontSize) {
            textView.font = NSFont.monospacedSystemFont(ofSize: CGFloat(fontSize), weight: .regular)
        }

        if textView.string != text {
            let selectedRange = textView.selectedRange()

            let attributedString = JSONSyntaxHighlighter.highlightJSON(text, theme: .material, fontSize: CGFloat(fontSize))
            textView.textStorage?.setAttributedString(attributedString)

            if selectedRange.location <= textView.string.count {
                textView.setSelectedRange(selectedRange)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: JSONTextEditorRepresentable

        init(_ parent: JSONTextEditorRepresentable) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }

            parent.text = textView.string

            let selectedRange = textView.selectedRange()
            let attributedString = JSONSyntaxHighlighter.highlightJSON(
                textView.string,
                theme: .material,
                fontSize: CGFloat(parent.fontSize)
            )
            textView.textStorage?.setAttributedString(attributedString)

            if selectedRange.location <= textView.string.count {
                textView.setSelectedRange(selectedRange)
            }
        }
    }
}

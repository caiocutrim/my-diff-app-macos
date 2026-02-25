//
//  JSONTextEditor.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI
import AppKit

/// TextEditor customizado com syntax highlighting em tempo real para JSON
struct JSONTextEditor: View {
    @Binding var text: String
    let placeholder: String
    @ObservedObject var fontSettings = FontSettings.shared

    var body: some View {
        JSONTextEditorRepresentable(text: $text, placeholder: placeholder, fontSize: fontSettings.fontSize)
    }
}

/// NSViewRepresentable para integrar NSTextView com syntax highlighting
struct JSONTextEditorRepresentable: NSViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let fontSize: Double

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        // Configurações do text view
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.allowsUndo = true
        textView.font = NSFont.monospacedSystemFont(ofSize: CGFloat(fontSize), weight: .regular)
        textView.textColor = NSColor(DraculaTheme.foreground)
        textView.backgroundColor = NSColor(DraculaTheme.background)
        textView.insertionPointColor = NSColor(DraculaTheme.foreground)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false

        // Padding
        textView.textContainerInset = NSSize(width: 8, height: 8)

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! NSTextView

        // Atualizar fonte se mudou
        if let currentFont = textView.font, currentFont.pointSize != CGFloat(fontSize) {
            textView.font = NSFont.monospacedSystemFont(ofSize: CGFloat(fontSize), weight: .regular)
        }

        // Só atualizar se o texto for diferente (evitar loop)
        if textView.string != text {
            // Salvar posição do cursor
            let selectedRange = textView.selectedRange()

            // Aplicar syntax highlighting com tamanho de fonte correto
            let attributedString = JSONSyntaxHighlighter.highlightJSON(text, theme: .dracula, fontSize: CGFloat(fontSize))
            textView.textStorage?.setAttributedString(attributedString)

            // Restaurar posição do cursor
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

            // Atualizar o binding
            parent.text = textView.string

            // Aplicar syntax highlighting com tamanho de fonte correto
            let selectedRange = textView.selectedRange()
            let attributedString = JSONSyntaxHighlighter.highlightJSON(
                textView.string,
                theme: .dracula,
                fontSize: CGFloat(parent.fontSize)
            )
            textView.textStorage?.setAttributedString(attributedString)

            // Restaurar cursor
            if selectedRange.location <= textView.string.count {
                textView.setSelectedRange(selectedRange)
            }
        }
    }
}

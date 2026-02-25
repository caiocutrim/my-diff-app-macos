//
//  JSONSyntaxHighlighter.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI
import AppKit

enum SyntaxTheme {
    case dracula
    case system
}

class JSONSyntaxHighlighter {

    /// Aplica syntax highlighting em JSON completo (para text editors)
    static func highlightJSON(_ text: String, theme: SyntaxTheme = .dracula, fontSize: CGFloat = 13) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)

        // Definir cores baseado no tema
        let (keyColor, stringColor, numberColor, boolNullColor, punctuationColor, textColor) = getThemeColors(theme)

        // Fonte monoespaçada com o tamanho especificado
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)

        // Aplicar fonte e cor padrão para todo o texto
        attributedString.addAttributes([
            .foregroundColor: textColor,
            .font: font
        ], range: NSRange(location: 0, length: attributedString.length))

        // Padrões de regex para JSON
        let patterns: [(pattern: String, color: NSColor)] = [
            // Chaves (string seguida de :)
            ("\"[^\"]*\"\\s*:", keyColor),
            // Strings (valores)
            ("\"[^\"]*\"", stringColor),
            // Números
            ("-?\\d+\\.?\\d*([eE][+-]?\\d+)?", numberColor),
            // Booleanos e null
            ("\\b(true|false|null)\\b", boolNullColor),
            // Pontuação
            ("[{}\\[\\],:]", punctuationColor)
        ]

        for (pattern, color) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let matches = regex.matches(
                    in: text,
                    options: [],
                    range: NSRange(location: 0, length: text.utf16.count)
                )

                for match in matches {
                    attributedString.addAttribute(
                        .foregroundColor,
                        value: color,
                        range: match.range
                    )
                }
            }
        }

        return attributedString
    }

    /// Aplica syntax highlighting em um segmento de texto JSON (para diff view)
    static func highlight(text: String, diffType: DiffSegmentType, theme: SyntaxTheme = .dracula, fontSize: CGFloat = 13) -> AttributedString {
        var attributed = AttributedString(text)

        // Aplicar tamanho de fonte
        attributed.font = Font.system(size: fontSize, design: .monospaced)

        // Cores baseadas no tema
        let (keyColor, stringColor, numberColor, boolNullColor, punctuationColor, _) = getThemeColorsSwiftUI(theme)

        // Background colors baseado no tipo de diff
        let backgroundColor: Color? = {
            switch diffType {
            case .unchanged:
                return nil
            case .added:
                return theme == .dracula ? DraculaTheme.diffAddedHighlight : Color.green.opacity(0.3)
            case .removed:
                return theme == .dracula ? DraculaTheme.diffRemovedHighlight : Color.red.opacity(0.3)
            case .modified:
                return theme == .dracula ? DraculaTheme.diffModifiedHighlight : Color.yellow.opacity(0.3)
            }
        }()

        // Aplicar background se necessário
        if let bgColor = backgroundColor {
            attributed.backgroundColor = bgColor
        }

        // Padrões de regex para JSON
        let patterns: [(pattern: String, color: Color)] = [
            ("\"[^\"]*\"\\s*:", keyColor),
            ("\"[^\"]*\"", stringColor),
            ("-?\\d+\\.?\\d*([eE][+-]?\\d+)?", numberColor),
            ("\\b(true|false|null)\\b", boolNullColor),
            ("[{}\\[\\],:]", punctuationColor)
        ]

        for (pattern, color) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let nsString = text as NSString
                let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

                for match in matches {
                    if let range = Range(match.range, in: text) {
                        if let attrRange = Range(range, in: attributed) {
                            attributed[attrRange].foregroundColor = color
                        }
                    }
                }
            }
        }

        return attributed
    }

    /// Cria um AttributedString para um array de CharacterDiff com syntax highlighting
    static func highlightSegments(_ segments: [CharacterDiff], theme: SyntaxTheme = .dracula, fontSize: CGFloat = 13) -> AttributedString {
        var result = AttributedString()

        for segment in segments {
            let highlighted = highlight(text: segment.text, diffType: segment.type, theme: theme, fontSize: fontSize)
            result.append(highlighted)
        }

        return result
    }

    // MARK: - Theme Colors

    private static func getThemeColors(_ theme: SyntaxTheme) -> (
        key: NSColor,
        string: NSColor,
        number: NSColor,
        boolNull: NSColor,
        punctuation: NSColor,
        text: NSColor
    ) {
        switch theme {
        case .dracula:
            return (
                key: NSColor(DraculaTheme.jsonKey),
                string: NSColor(DraculaTheme.jsonString),
                number: NSColor(DraculaTheme.jsonNumber),
                boolNull: NSColor(DraculaTheme.jsonBoolean),
                punctuation: NSColor(DraculaTheme.jsonPunctuation),
                text: NSColor(DraculaTheme.foreground)
            )
        case .system:
            return (
                key: NSColor.purple,
                string: NSColor.red,
                number: NSColor.blue,
                boolNull: NSColor.orange,
                punctuation: NSColor.secondaryLabelColor,
                text: NSColor.labelColor
            )
        }
    }

    private static func getThemeColorsSwiftUI(_ theme: SyntaxTheme) -> (
        key: Color,
        string: Color,
        number: Color,
        boolNull: Color,
        punctuation: Color,
        text: Color
    ) {
        switch theme {
        case .dracula:
            return (
                key: DraculaTheme.jsonKey,
                string: DraculaTheme.jsonString,
                number: DraculaTheme.jsonNumber,
                boolNull: DraculaTheme.jsonBoolean,
                punctuation: DraculaTheme.jsonPunctuation,
                text: DraculaTheme.foreground
            )
        case .system:
            return (
                key: Color.purple,
                string: Color.red,
                number: Color.blue,
                boolNull: Color.orange,
                punctuation: Color.secondary,
                text: Color.primary
            )
        }
    }
}

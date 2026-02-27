//
//  JSONSyntaxHighlighter.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI
import AppKit

enum SyntaxTheme {
    case material
    case system
}

class JSONSyntaxHighlighter {

    /// Aplica syntax highlighting em JSON completo (para text editors)
    static func highlightJSON(_ text: String, theme: SyntaxTheme = .material, fontSize: CGFloat = 13) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)

        let (keyColor, stringColor, numberColor, boolNullColor, punctuationColor, textColor) = getThemeColors(theme)
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)

        attributedString.addAttributes([
            .foregroundColor: textColor,
            .font: font
        ], range: NSRange(location: 0, length: attributedString.length))

        let patterns: [(pattern: String, color: NSColor)] = [
            ("\"[^\"]*\"\\s*:", keyColor),
            ("\"[^\"]*\"", stringColor),
            ("-?\\d+\\.?\\d*([eE][+-]?\\d+)?", numberColor),
            ("\\b(true|false|null)\\b", boolNullColor),
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
    static func highlight(text: String, diffType: DiffSegmentType, theme: SyntaxTheme = .material, fontSize: CGFloat = 13, inlineHighlight: Bool = true) -> AttributedString {
        var attributed = AttributedString(text)

        attributed.font = Font.system(size: fontSize, design: .monospaced)

        let (keyColor, stringColor, numberColor, boolNullColor, punctuationColor, _) = getThemeColorsSwiftUI(theme)

        // Only apply inline segment backgrounds when inlineHighlight is enabled
        // (i.e. for modified lines only — added/removed lines use the row background instead)
        if inlineHighlight {
            let backgroundColor: Color? = {
                switch diffType {
                case .unchanged: return nil
                case .added: return AppTheme.addHighlight
                case .removed: return AppTheme.delHighlight
                case .modified: return AppTheme.modHighlight
                }
            }()
            if let bgColor = backgroundColor {
                attributed.backgroundColor = bgColor
            }
        }

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
    static func highlightSegments(_ segments: [CharacterDiff], theme: SyntaxTheme = .material, fontSize: CGFloat = 13, inlineHighlight: Bool = true) -> AttributedString {
        var result = AttributedString()

        for segment in segments {
            let highlighted = highlight(text: segment.text, diffType: segment.type, theme: theme, fontSize: fontSize, inlineHighlight: inlineHighlight)
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
        case .material:
            return (
                key: NSColor(AppTheme.jsonKey),
                string: NSColor(AppTheme.jsonString),
                number: NSColor(AppTheme.jsonNumber),
                boolNull: NSColor(AppTheme.jsonBoolean),
                punctuation: NSColor(AppTheme.jsonPunctuation),
                text: NSColor(AppTheme.text)
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
        case .material:
            return (
                key: AppTheme.jsonKey,
                string: AppTheme.jsonString,
                number: AppTheme.jsonNumber,
                boolNull: AppTheme.jsonBoolean,
                punctuation: AppTheme.jsonPunctuation,
                text: AppTheme.text
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

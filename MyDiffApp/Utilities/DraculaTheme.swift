//
//  DraculaTheme.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI

/// Cores oficiais do tema Dracula
/// Referência: https://draculatheme.com/contribute
struct DraculaTheme {

    // MARK: - Background Colors
    static let background = Color(hex: "#282a36")      // Fundo principal
    static let currentLine = Color(hex: "#44475a")     // Linha atual
    static let selection = Color(hex: "#44475a")       // Seleção
    static let foreground = Color(hex: "#f8f8f2")      // Texto padrão

    // MARK: - Syntax Colors
    static let comment = Color(hex: "#6272a4")         // Comentários
    static let cyan = Color(hex: "#8be9fd")            // Cyan
    static let green = Color(hex: "#50fa7b")           // Verde
    static let orange = Color(hex: "#ffb86c")          // Laranja
    static let pink = Color(hex: "#ff79c6")            // Rosa
    static let purple = Color(hex: "#bd93f9")          // Roxo
    static let red = Color(hex: "#ff5555")             // Vermelho
    static let yellow = Color(hex: "#f1fa8c")          // Amarelo

    // MARK: - JSON Syntax Mapping
    static let jsonKey = purple           // Chaves JSON
    static let jsonString = yellow        // Strings
    static let jsonNumber = purple        // Números
    static let jsonBoolean = pink         // Booleanos
    static let jsonNull = pink            // Null
    static let jsonPunctuation = foreground  // Pontuação

    // MARK: - Diff Colors
    static let diffAdded = green.opacity(0.3)         // Adicionado
    static let diffRemoved = red.opacity(0.3)         // Removido
    static let diffModified = orange.opacity(0.3)     // Modificado

    static let diffAddedHighlight = green.opacity(0.5)
    static let diffRemovedHighlight = red.opacity(0.5)
    static let diffModifiedHighlight = orange.opacity(0.5)
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

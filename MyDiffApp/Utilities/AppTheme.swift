//
//  AppTheme.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI

/// GitHub-dark theme colors (matching the HTML reference design)
struct AppTheme {

    // MARK: - Background & Surface
    static let background = Color(hex: "#0d1117")
    static let surface = Color(hex: "#161b22")
    static let surface2 = Color(hex: "#1c2128")

    // MARK: - Borders
    static let border = Color(hex: "#30363d")
    static let borderSubtle = Color(hex: "#21262d")

    // MARK: - Text Hierarchy
    static let text = Color(hex: "#e6edf3")
    static let textMuted = Color(hex: "#7d8590")
    static let textDim = Color(hex: "#484f58")

    // MARK: - Accent
    static let accent = Color(hex: "#58a6ff")
    static let accentHover = Color(hex: "#79b8ff")

    // MARK: - Added (Green)
    static let addBg = Color(hex: "#3fb950").opacity(0.08)
    static let addLine = Color(hex: "#3fb950").opacity(0.3)
    static let addText = Color(hex: "#3fb950")
    static let addGutter = Color(hex: "#3fb950").opacity(0.15)
    static let addHighlight = Color(hex: "#3fb950").opacity(0.3)

    // MARK: - Removed (Red)
    static let delBg = Color(hex: "#f85149").opacity(0.08)
    static let delLine = Color(hex: "#f85149").opacity(0.3)
    static let delText = Color(hex: "#f85149")
    static let delGutter = Color(hex: "#f85149").opacity(0.15)
    static let delHighlight = Color(hex: "#f85149").opacity(0.3)

    // MARK: - Modified (Orange/Yellow)
    static let modBg = Color(hex: "#d29922").opacity(0.08)
    static let modLine = Color(hex: "#d29922").opacity(0.3)
    static let modText = Color(hex: "#d29922")
    static let modGutter = Color(hex: "#d29922").opacity(0.15)
    static let modHighlight = Color(hex: "#d29922").opacity(0.3)

    // MARK: - JSON Syntax (GitHub-dark style)
    static let jsonKey = Color(hex: "#79b8ff")
    static let jsonString = Color(hex: "#a5d6ff")
    static let jsonNumber = Color(hex: "#d2a679")
    static let jsonBoolean = Color(hex: "#79b8ff")
    static let jsonNull = Color(hex: "#7d8590")
    static let jsonPunctuation = Color(hex: "#7d8590")

    // MARK: - UI Dimensions
    static let radius: CGFloat = 8
    static let radiusSm: CGFloat = 5
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

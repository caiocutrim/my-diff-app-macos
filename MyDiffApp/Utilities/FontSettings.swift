//
//  FontSettings.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI

/// Gerenciador de configurações de fonte do app
class FontSettings: ObservableObject {

    /// Tamanho da fonte padrão
    static let defaultSize: CGFloat = 13

    /// Tamanho mínimo permitido
    static let minSize: CGFloat = 10

    /// Tamanho máximo permitido
    static let maxSize: CGFloat = 24

    /// Tamanho da fonte atual (persistido)
    @AppStorage("fontSize") var fontSize: Double = defaultSize

    /// Singleton para acesso global
    static let shared = FontSettings()

    private init() {}

    /// Retorna um NSFont monoespaçado com o tamanho atual
    var monospacedFont: NSFont {
        NSFont.monospacedSystemFont(ofSize: CGFloat(fontSize), weight: .regular)
    }

    /// Retorna um Font SwiftUI monoespaçado com o tamanho atual
    var swiftUIMonospacedFont: Font {
        .system(size: CGFloat(fontSize), design: .monospaced)
    }

    /// Aumenta o tamanho da fonte
    func increase() {
        fontSize = min(fontSize + 1, FontSettings.maxSize)
    }

    /// Diminui o tamanho da fonte
    func decrease() {
        fontSize = max(fontSize - 1, FontSettings.minSize)
    }

    /// Reseta para o tamanho padrão
    func reset() {
        fontSize = FontSettings.defaultSize
    }
}

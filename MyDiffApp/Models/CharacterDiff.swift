//
//  CharacterDiff.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import Foundation

/// Representa um segmento de texto com informação de diff
struct CharacterDiff: Identifiable {
    let id = UUID()
    let text: String
    let type: DiffSegmentType
}

enum DiffSegmentType {
    case unchanged   // Texto igual em ambos lados
    case added       // Texto adicionado (só no lado direito)
    case removed     // Texto removido (só no lado esquerdo)
    case modified    // Texto modificado (diferente em ambos lados)
}

/// Representa uma linha com diff character-level
struct DetailedDiffLine: Identifiable {
    let id = UUID()
    let leftSegments: [CharacterDiff]
    let rightSegments: [CharacterDiff]
    /// Número de linha no lado esquerdo. nil para linhas puramente adicionadas.
    let leftLineNumber: Int?
    /// Número de linha no lado direito. nil para linhas puramente removidas.
    let rightLineNumber: Int?
    let type: DiffLineType
}

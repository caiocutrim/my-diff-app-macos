//
//  DiffEngine.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import Foundation

class DiffEngine {

    /// Compara duas strings linha por linha e retorna o resultado do diff
    static func compare(left: String, right: String) -> DiffResult {
        let leftLines = left.components(separatedBy: .newlines)
        let rightLines = right.components(separatedBy: .newlines)

        var diffLines: [DiffLine] = []
        let maxLines = max(leftLines.count, rightLines.count)

        for i in 0..<maxLines {
            let leftContent = i < leftLines.count ? leftLines[i] : nil
            let rightContent = i < rightLines.count ? rightLines[i] : nil

            let type: DiffLineType

            if leftContent == nil && rightContent != nil {
                // Linha adicionada (existe apenas no lado direito)
                type = .added
            } else if leftContent != nil && rightContent == nil {
                // Linha removida (existe apenas no lado esquerdo)
                type = .removed
            } else if leftContent == rightContent {
                // Linhas iguais
                type = .equal
            } else {
                // Linhas modificadas (diferentes em ambos lados)
                type = .modified
            }

            let diffLine = DiffLine(
                leftContent: leftContent,
                rightContent: rightContent,
                lineNumber: i + 1,
                type: type
            )

            diffLines.append(diffLine)
        }

        return DiffResult(
            lines: diffLines,
            leftOriginal: left,
            rightOriginal: right
        )
    }

    /// Compara duas strings com diff character-level para cada linha
    static func compareDetailed(left: String, right: String) -> [DetailedDiffLine] {
        let leftLines = left.components(separatedBy: .newlines)
        let rightLines = right.components(separatedBy: .newlines)

        var detailedLines: [DetailedDiffLine] = []
        let maxLines = max(leftLines.count, rightLines.count)

        for i in 0..<maxLines {
            let leftContent = i < leftLines.count ? leftLines[i] : nil
            let rightContent = i < rightLines.count ? rightLines[i] : nil

            let type: DiffLineType

            if leftContent == nil && rightContent != nil {
                type = .added
            } else if leftContent != nil && rightContent == nil {
                type = .removed
            } else if leftContent == rightContent {
                type = .equal
            } else {
                type = .modified
            }

            // Usar CharacterDiffEngine para comparação character-level
            let (leftSegments, rightSegments) = CharacterDiffEngine.compareStrings(
                left: leftContent,
                right: rightContent
            )

            let detailedLine = DetailedDiffLine(
                leftSegments: leftSegments,
                rightSegments: rightSegments,
                lineNumber: i + 1,
                type: type
            )

            detailedLines.append(detailedLine)
        }

        return detailedLines
    }
}

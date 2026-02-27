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

    /// Extrai um resumo das diferenças identificando campos JSON alterados
    static func extractSummary(from lines: [DetailedDiffLine]) -> [DiffSummaryItem] {
        var items: [DiffSummaryItem] = []

        for line in lines where line.type != .equal {
            let leftText = line.leftSegments.map { $0.text }.joined().trimmingCharacters(in: .whitespaces)
            let rightText = line.rightSegments.map { $0.text }.joined().trimmingCharacters(in: .whitespaces)

            // Extrair nome do campo e valor de uma linha JSON tipo "key": value
            let (leftKey, leftVal) = parseJSONLine(leftText)
            let (rightKey, rightVal) = parseJSONLine(rightText)

            let fieldName = leftKey ?? rightKey ?? leftText.prefix(40).description

            // Pular linhas que são apenas chaves/colchetes
            if fieldName.isEmpty || fieldName == "{" || fieldName == "}" || fieldName == "[" || fieldName == "]" {
                continue
            }

            let changeType: DiffChangeType
            switch line.type {
            case .added:
                changeType = .added
            case .removed:
                changeType = .removed
            default:
                changeType = .modified
            }

            let item = DiffSummaryItem(
                fieldName: fieldName,
                oldValue: leftVal ?? (leftText.isEmpty ? nil : leftText),
                newValue: rightVal ?? (rightText.isEmpty ? nil : rightText),
                changeType: changeType
            )
            items.append(item)
        }

        return items
    }

    /// Extrai chave e valor de uma linha JSON formatada como `"key": value`
    private static func parseJSONLine(_ line: String) -> (key: String?, value: String?) {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return (nil, nil) }

        // Match "key": value pattern
        let pattern = #"^"([^"]+)"\s*:\s*(.+?)[\s,]*$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
              match.numberOfRanges >= 3 else {
            return (nil, nil)
        }

        let keyRange = Range(match.range(at: 1), in: trimmed)
        let valRange = Range(match.range(at: 2), in: trimmed)

        let key = keyRange.map { String(trimmed[$0]) }
        let value = valRange.map { String(trimmed[$0]) }

        return (key, value)
    }
}

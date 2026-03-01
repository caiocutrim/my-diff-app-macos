//
//  DiffEngine.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import Foundation

class DiffEngine {

    // MARK: - Public API

    /// Compara duas strings linha por linha (posicional, legado)
    static func compare(left: String, right: String) -> DiffResult {
        let leftLines = left.components(separatedBy: .newlines)
        let rightLines = right.components(separatedBy: .newlines)

        var diffLines: [DiffLine] = []
        let maxLines = max(leftLines.count, rightLines.count)

        for i in 0..<maxLines {
            let leftContent = i < leftLines.count ? leftLines[i] : nil
            let rightContent = i < rightLines.count ? rightLines[i] : nil

            let type: DiffLineType
            if leftContent == nil { type = .added }
            else if rightContent == nil { type = .removed }
            else if leftContent == rightContent { type = .equal }
            else { type = .modified }

            diffLines.append(DiffLine(
                leftContent: leftContent,
                rightContent: rightContent,
                lineNumber: i + 1,
                type: type
            ))
        }

        return DiffResult(lines: diffLines, leftOriginal: left, rightOriginal: right)
    }

    /// Compara duas strings usando LCS line-level + character-level diff para linhas modificadas
    static func compareDetailed(left: String, right: String) -> [DetailedDiffLine] {
        let leftLines = left.components(separatedBy: .newlines)
        let rightLines = right.components(separatedBy: .newlines)

        let ops = lcsEditScript(leftLines, rightLines)

        var result: [DetailedDiffLine] = []
        var i = 0

        while i < ops.count {
            let op = ops[i]

            switch op {
            case .equal(let li, let ri):
                let text = leftLines[li]
                result.append(DetailedDiffLine(
                    leftSegments:  [CharacterDiff(text: text, type: .unchanged)],
                    rightSegments: [CharacterDiff(text: rightLines[ri], type: .unchanged)],
                    leftLineNumber:  li + 1,
                    rightLineNumber: ri + 1,
                    type: .equal
                ))
                i += 1

            case .removed(let li):
                // Look ahead: if the very next op is .added and they share the same JSON key,
                // pair them as a single modified row with character-level diff.
                if i + 1 < ops.count,
                   case .added(let ri) = ops[i + 1],
                   sameJSONKey(leftLines[li], rightLines[ri]) {

                    let (ls, rs) = CharacterDiffEngine.compareStrings(
                        left: leftLines[li], right: rightLines[ri])
                    result.append(DetailedDiffLine(
                        leftSegments:  ls,
                        rightSegments: rs,
                        leftLineNumber:  li + 1,
                        rightLineNumber: ri + 1,
                        type: .modified
                    ))
                    i += 2
                } else {
                    result.append(DetailedDiffLine(
                        leftSegments:  [CharacterDiff(text: leftLines[li], type: .removed)],
                        rightSegments: [],
                        leftLineNumber:  li + 1,
                        rightLineNumber: nil,
                        type: .removed
                    ))
                    i += 1
                }

            case .added(let ri):
                result.append(DetailedDiffLine(
                    leftSegments:  [],
                    rightSegments: [CharacterDiff(text: rightLines[ri], type: .added)],
                    leftLineNumber:  nil,
                    rightLineNumber: ri + 1,
                    type: .added
                ))
                i += 1
            }
        }

        return result
    }

    /// Extrai um resumo semântico das diferenças (apenas linhas com chave JSON identificável)
    static func extractSummary(from lines: [DetailedDiffLine]) -> [DiffSummaryItem] {
        var items: [DiffSummaryItem] = []

        for line in lines where line.type != .equal {
            let leftText  = line.leftSegments.map  { $0.text }.joined().trimmingCharacters(in: .whitespaces)
            let rightText = line.rightSegments.map { $0.text }.joined().trimmingCharacters(in: .whitespaces)

            let (leftKey, leftVal)   = parseJSONLine(leftText)
            let (rightKey, rightVal) = parseJSONLine(rightText)

            let fieldName = leftKey ?? rightKey ?? ""

            // Ignorar linhas sem chave identificável (chaves, colchetes, vírgulas isoladas)
            guard !fieldName.isEmpty else { continue }

            let changeType: DiffChangeType
            switch line.type {
            case .added:    changeType = .added
            case .removed:  changeType = .removed
            default:        changeType = .modified
            }

            items.append(DiffSummaryItem(
                lineID:    line.id,
                fieldName: fieldName,
                oldValue:  leftVal  ?? (leftText.isEmpty  ? nil : leftText),
                newValue:  rightVal ?? (rightText.isEmpty ? nil : rightText),
                changeType: changeType
            ))
        }

        return items
    }

    // MARK: - LCS Line Diff

    private enum EditOp {
        case equal(Int, Int)   // (leftIdx, rightIdx)
        case removed(Int)      // leftIdx only
        case added(Int)        // rightIdx only
    }

    /// Produces the shortest edit script using LCS on full lines.
    private static func lcsEditScript(_ left: [String], _ right: [String]) -> [EditOp] {
        let n = left.count
        let m = right.count

        guard n > 0 || m > 0 else { return [] }

        // Build LCS DP table  O(n·m) — fine for typical JSON files
        var dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        for i in 1...n {
            for j in 1...m {
                if left[i - 1] == right[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }

        // Backtrack to build edit script
        var ops: [EditOp] = []
        var i = n, j = m
        while i > 0 || j > 0 {
            if i > 0 && j > 0 && left[i - 1] == right[j - 1] {
                ops.append(.equal(i - 1, j - 1))
                i -= 1; j -= 1
            } else if j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j]) {
                ops.append(.added(j - 1))
                j -= 1
            } else {
                ops.append(.removed(i - 1))
                i -= 1
            }
        }

        return ops.reversed()
    }

    // MARK: - Helpers

    /// Returns true if both lines are JSON key-value pairs with the same key name.
    private static func sameJSONKey(_ left: String, _ right: String) -> Bool {
        guard let lk = extractJSONKey(left), let rk = extractJSONKey(right) else { return false }
        return lk == rk
    }

    /// Extracts the key name from a formatted JSON line like `  "age" : 36,`
    private static func extractJSONKey(_ line: String) -> String? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard let regex = try? NSRegularExpression(pattern: #"^"([^"]+)"\s*:"#),
              let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
              let range = Range(match.range(at: 1), in: trimmed) else { return nil }
        return String(trimmed[range])
    }

    /// Extracts key and value from a formatted JSON line like `"key": value`
    private static func parseJSONLine(_ line: String) -> (key: String?, value: String?) {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return (nil, nil) }

        let pattern = #"^"([^"]+)"\s*:\s*(.+?)[\s,]*$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
              match.numberOfRanges >= 3 else { return (nil, nil) }

        let key   = Range(match.range(at: 1), in: trimmed).map { String(trimmed[$0]) }
        let value = Range(match.range(at: 2), in: trimmed).map { String(trimmed[$0]) }
        return (key, value)
    }
}

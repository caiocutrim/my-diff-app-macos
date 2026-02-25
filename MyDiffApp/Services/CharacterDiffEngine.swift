//
//  CharacterDiffEngine.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import Foundation

class CharacterDiffEngine {

    /// Compara duas strings character por character e retorna segmentos com diferenças
    static func compareStrings(left: String?, right: String?) -> (left: [CharacterDiff], right: [CharacterDiff]) {
        guard let left = left, let right = right else {
            // Se uma das strings é nil, retorna a outra como adicionada/removida
            if let left = left {
                return ([CharacterDiff(text: left, type: .removed)], [])
            } else if let right = right {
                return ([], [CharacterDiff(text: right, type: .added)])
            }
            return ([], [])
        }

        // Se as strings são idênticas, retorna tudo como unchanged
        if left == right {
            return (
                [CharacterDiff(text: left, type: .unchanged)],
                [CharacterDiff(text: right, type: .unchanged)]
            )
        }

        // Usar algoritmo de diff character-level
        let leftChars = Array(left)
        let rightChars = Array(right)

        let diffs = computeDiff(leftChars, rightChars)

        var leftSegments: [CharacterDiff] = []
        var rightSegments: [CharacterDiff] = []

        var leftBuffer = ""
        var rightBuffer = ""
        var lastType: DiffSegmentType?

        for diff in diffs {
            if lastType != diff.type && lastType != nil {
                // Flush buffers
                if !leftBuffer.isEmpty {
                    leftSegments.append(CharacterDiff(text: leftBuffer, type: lastType!))
                    leftBuffer = ""
                }
                if !rightBuffer.isEmpty {
                    rightSegments.append(CharacterDiff(text: rightBuffer, type: lastType!))
                    rightBuffer = ""
                }
            }

            switch diff.type {
            case .unchanged:
                leftBuffer += String(diff.char)
                rightBuffer += String(diff.char)
            case .removed:
                leftBuffer += String(diff.char)
            case .added:
                rightBuffer += String(diff.char)
            case .modified:
                // Para modified, tratamos como removed + added
                break
            }

            lastType = diff.type
        }

        // Flush final buffers
        if !leftBuffer.isEmpty, let type = lastType {
            leftSegments.append(CharacterDiff(text: leftBuffer, type: type))
        }
        if !rightBuffer.isEmpty, let type = lastType {
            rightSegments.append(CharacterDiff(text: rightBuffer, type: type))
        }

        return (leftSegments, rightSegments)
    }

    private struct CharDiff {
        let char: Character
        let type: DiffSegmentType
    }

    /// Algoritmo simples de diff baseado em Longest Common Subsequence (LCS)
    private static func computeDiff(_ left: [Character], _ right: [Character]) -> [CharDiff] {
        let lcs = longestCommonSubsequence(left, right)
        var result: [CharDiff] = []

        var i = 0, j = 0, k = 0

        while i < left.count || j < right.count {
            if k < lcs.count {
                let commonChar = lcs[k]

                // Adicionar caracteres removidos antes do comum
                while i < left.count && left[i] != commonChar {
                    result.append(CharDiff(char: left[i], type: .removed))
                    i += 1
                }

                // Adicionar caracteres adicionados antes do comum
                while j < right.count && right[j] != commonChar {
                    result.append(CharDiff(char: right[j], type: .added))
                    j += 1
                }

                // Adicionar caractere comum
                if i < left.count && left[i] == commonChar {
                    result.append(CharDiff(char: commonChar, type: .unchanged))
                    i += 1
                    j += 1
                    k += 1
                }
            } else {
                // Resto são diferenças
                while i < left.count {
                    result.append(CharDiff(char: left[i], type: .removed))
                    i += 1
                }
                while j < right.count {
                    result.append(CharDiff(char: right[j], type: .added))
                    j += 1
                }
            }
        }

        return result
    }

    /// Encontra a maior subsequência comum entre duas sequências
    private static func longestCommonSubsequence(_ a: [Character], _ b: [Character]) -> [Character] {
        let m = a.count
        let n = b.count

        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 1...m {
            for j in 1...n {
                if a[i - 1] == b[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }

        // Reconstruir LCS
        var lcs: [Character] = []
        var i = m, j = n

        while i > 0 && j > 0 {
            if a[i - 1] == b[j - 1] {
                lcs.insert(a[i - 1], at: 0)
                i -= 1
                j -= 1
            } else if dp[i - 1][j] > dp[i][j - 1] {
                i -= 1
            } else {
                j -= 1
            }
        }

        return lcs
    }
}

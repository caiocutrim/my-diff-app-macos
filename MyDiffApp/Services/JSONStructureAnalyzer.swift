//
//  JSONStructureAnalyzer.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import Foundation

// MARK: - Public result

struct StructureWarning {
    let message: String
    let similarity: Double   // 0.0 – 1.0, for reference
}

// MARK: - Analyzer

enum JSONStructureAnalyzer {

    /// Compares the structural shape of two already-formatted JSON strings.
    /// Returns a warning when the structures differ enough to make the diff
    /// output misleading, or nil when the comparison should be meaningful.
    static func analyze(left: String, right: String) -> StructureWarning? {
        guard
            let leftData  = left.data(using: .utf8),
            let rightData = right.data(using: .utf8),
            let leftObj   = try? JSONSerialization.jsonObject(with: leftData),
            let rightObj  = try? JSONSerialization.jsonObject(with: rightData)
        else { return nil }

        let leftType  = rootType(of: leftObj)
        let rightType = rootType(of: rightObj)

        // Root type mismatch (object vs array, etc.)
        if leftType != rightType {
            return StructureWarning(
                message: "Estruturas raiz incompatíveis: o JSON original é \(leftType.label) "
                       + "e o comparado é \(rightType.label). "
                       + "O diff vai mostrar quase tudo como removido/adicionado em vez das diferenças reais.",
                similarity: 0
            )
        }

        // Collect key paths up to depth 2 from both documents
        let leftKeys  = keyPaths(from: leftObj,  maxDepth: 2)
        let rightKeys = keyPaths(from: rightObj, maxDepth: 2)

        // Nothing to compare structurally (e.g., both are primitive arrays)
        guard !leftKeys.isEmpty || !rightKeys.isEmpty else { return nil }

        let intersection = leftKeys.intersection(rightKeys)
        let union        = leftKeys.union(rightKeys)
        let similarity   = union.isEmpty ? 1.0 : Double(intersection.count) / Double(union.count)

        if similarity == 0 {
            return StructureWarning(
                message: "Nenhuma chave em comum foi encontrada entre os dois JSONs. "
                       + "Os documentos parecem ter schemas completamente diferentes — "
                       + "o resultado do diff pode não ser útil.",
                similarity: 0
            )
        }

        if similarity < 0.20 {
            let pct = Int((similarity * 100).rounded())
            return StructureWarning(
                message: "Apenas \(pct)% das chaves são compartilhadas entre os dois JSONs. "
                       + "Os documentos têm estruturas muito diferentes — "
                       + "o diff vai exibir a maioria das linhas como adicionadas ou removidas "
                       + "em vez das diferenças reais.",
                similarity: similarity
            )
        }

        return nil
    }

    // MARK: - Helpers

    private enum RootType: Equatable {
        case object, array, primitive
        var label: String {
            switch self {
            case .object:    return "objeto {}"
            case .array:     return "array []"
            case .primitive: return "valor primitivo"
            }
        }
    }

    private static func rootType(of value: Any) -> RootType {
        if value is [String: Any] { return .object }
        if value is [Any]         { return .array  }
        return .primitive
    }

    /// Recursively collects dot-separated key paths up to `maxDepth`.
    /// For arrays, inspects the first element as representative.
    private static func keyPaths(from value: Any, maxDepth: Int, prefix: String = "") -> Set<String> {
        guard maxDepth > 0 else { return [] }
        var result = Set<String>()

        if let dict = value as? [String: Any] {
            for (key, child) in dict {
                let path = prefix.isEmpty ? key : "\(prefix).\(key)"
                result.insert(path)
                result.formUnion(keyPaths(from: child, maxDepth: maxDepth - 1, prefix: path))
            }
        } else if let array = value as? [Any], let first = array.first {
            result.formUnion(keyPaths(from: first, maxDepth: maxDepth - 1, prefix: prefix))
        }

        return result
    }
}

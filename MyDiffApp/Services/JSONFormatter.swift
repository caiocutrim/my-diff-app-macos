//
//  JSONFormatter.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import Foundation

enum JSONError: Error {
    case invalidJSON(String)
    case encodingError

    var localizedDescription: String {
        switch self {
        case .invalidJSON(let message):
            return "JSON inválido: \(message)"
        case .encodingError:
            return "Erro ao codificar JSON"
        }
    }
}

class JSONFormatter {

    /// Valida se uma string é um JSON válido
    static func validate(jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else {
            return false
        }

        do {
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            return true
        } catch {
            return false
        }
    }

    /// Formata uma string JSON com indentação e ordenação de chaves
    static func format(jsonString: String) -> Result<String, JSONError> {
        guard let data = jsonString.data(using: .utf8) else {
            return .failure(.invalidJSON("Não foi possível converter para dados"))
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

            let formattedData = try JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted, .sortedKeys]
            )

            guard let formattedString = String(data: formattedData, encoding: .utf8) else {
                return .failure(.encodingError)
            }

            return .success(formattedString)

        } catch {
            return .failure(.invalidJSON(error.localizedDescription))
        }
    }
}

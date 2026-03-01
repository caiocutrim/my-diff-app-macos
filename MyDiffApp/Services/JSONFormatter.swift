//
//  JSONFormatter.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import Foundation

// MARK: - Parse location

struct JSONParseLocation {
    let line: Int     // 1-based
    let column: Int   // 1-based
    let offset: Int   // 0-based character offset in source text
}

// MARK: - Error type

enum JSONError: Error {
    case encodingError
    case parseError(message: String, location: JSONParseLocation?)

    var localizedDescription: String {
        switch self {
        case .encodingError:
            return "Erro ao codificar JSON"
        case .parseError(let message, _):
            return message
        }
    }

    var location: JSONParseLocation? {
        if case .parseError(_, let loc) = self { return loc }
        return nil
    }
}

// MARK: - Formatter

class JSONFormatter {

    static func validate(jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data)) != nil
    }

    static func format(jsonString: String) -> Result<String, JSONError> {
        guard let data = jsonString.data(using: .utf8) else {
            return .failure(.parseError(message: "Não foi possível converter para dados", location: nil))
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let formatted  = try JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted, .sortedKeys]
            )
            guard let result = String(data: formatted, encoding: .utf8) else {
                return .failure(.encodingError)
            }
            return .success(result)

        } catch let nsError as NSError {
            let location = extractLocation(from: nsError, in: jsonString)
            let message  = friendlyMessage(from: nsError, location: location)
            return .failure(.parseError(message: message, location: location))
        }
    }

    // MARK: - Error location extraction

    /// Extracts line/column from a JSONSerialization NSError.
    /// Foundation puts the character offset in the debug description:
    /// e.g. "No value for key in object around character 32."
    private static func extractLocation(from error: NSError, in text: String) -> JSONParseLocation? {
        let description = (error.userInfo[NSDebugDescriptionErrorKey] as? String)
                        ?? error.localizedDescription

        // Try to parse "around character N" / "at character N"
        let pattern = #"(?:around|at) character (\d+)"#
        if let regex   = try? NSRegularExpression(pattern: pattern),
           let match   = regex.firstMatch(in: description, range: NSRange(description.startIndex..., in: description)),
           let range   = Range(match.range(at: 1), in: description),
           let rawOff  = Int(description[range]) {
            // Foundation reports 1-based offsets; clamp to valid range
            let offset = max(0, min(rawOff - 1, text.count - 1))
            return locationFromOffset(offset, in: text)
        }

        // For "end of file" errors the Foundation message carries no offset.
        // Point to the last non-empty line — that's where the closing token is missing.
        if description.contains("end of file") || description.contains("Unexpected end") {
            let lines = text.components(separatedBy: "\n")
            let lastNonEmpty = lines.enumerated().last { !$0.element.trimmingCharacters(in: .whitespaces).isEmpty }
            let lineNumber = (lastNonEmpty?.offset ?? 0) + 1
            let column     = (lastNonEmpty?.element.count ?? 0) + 1
            return JSONParseLocation(line: lineNumber, column: column, offset: text.count)
        }

        return nil
    }

    /// Converts a 0-based character offset to line + column (both 1-based).
    private static func locationFromOffset(_ offset: Int, in text: String) -> JSONParseLocation {
        var line   = 1
        var column = 1
        var idx    = text.startIndex

        for _ in 0..<offset {
            guard idx < text.endIndex else { break }
            if text[idx] == "\n" { line += 1; column = 1 } else { column += 1 }
            idx = text.index(after: idx)
        }

        return JSONParseLocation(line: line, column: column, offset: offset)
    }

    /// Translates the raw Foundation error message into something readable.
    private static func friendlyMessage(from error: NSError, location: JSONParseLocation?) -> String {
        let desc = (error.userInfo[NSDebugDescriptionErrorKey] as? String) ?? ""
        let where_ = location.map { " (linha \($0.line), col \($0.column))" } ?? ""

        if desc.contains("No value for key")   { return "Falta ':' após uma chave\(where_)" }
        if desc.contains("Trailing comma")     { return "Vírgula extra no final\(where_)" }
        if desc.contains("Unterminated string"){ return "String sem fechar\(where_)" }
        if desc.contains("Invalid value")      { return "Valor inválido\(where_)" }
        if desc.contains("Badly formed object"){ return "Objeto mal formado\(where_)" }
        if desc.contains("end of file")        { return "JSON incompleto — fechamento faltando\(where_)" }

        return "JSON inválido\(where_)"
    }
}

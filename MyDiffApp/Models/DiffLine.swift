//
//  DiffLine.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import Foundation

enum DiffLineType {
    case equal
    case added
    case removed
    case modified
}

struct DiffLine: Identifiable {
    let id = UUID()
    let leftContent: String?
    let rightContent: String?
    let lineNumber: Int
    let type: DiffLineType
}

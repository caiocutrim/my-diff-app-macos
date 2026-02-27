//
//  DiffSummary.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import Foundation

enum DiffChangeType {
    case modified
    case added
    case removed
}

struct DiffSummaryItem: Identifiable {
    let id = UUID()
    let fieldName: String
    let oldValue: String?
    let newValue: String?
    let changeType: DiffChangeType
}

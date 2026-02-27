//
//  DetailedDiffResultView.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI

struct DetailedDiffResultView: View {
    let detailedLines: [DetailedDiffLine]
    @Binding var showSummary: Bool
    /// UUID of the row to scroll both panes to simultaneously.
    @State private var scrollTarget: UUID? = nil

    private var summaryItems: [DiffSummaryItem] {
        DiffEngine.extractSummary(from: detailedLines)
    }

    var body: some View {
        VStack(spacing: 0) {
            HSplitView {
                // Left pane
                VStack(spacing: 0) {
                    PaneHeaderView(
                        icon: "doc.text",
                        title: "Original",
                        subtitle: "(Esquerda)",
                        filename: "original.json"
                    )
                    DetailedDiffPaneView(
                        lines: detailedLines,
                        showLeft: true,
                        scrollTarget: $scrollTarget
                    )
                    .background(AppTheme.background)
                }

                // Right pane
                VStack(spacing: 0) {
                    PaneHeaderView(
                        icon: "doc.on.clipboard",
                        title: "Comparado",
                        subtitle: "(Direita)",
                        filename: "comparado.json"
                    )
                    DetailedDiffPaneView(
                        lines: detailedLines,
                        showLeft: false,
                        scrollTarget: $scrollTarget
                    )
                    .background(AppTheme.background)
                }
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(AppTheme.border),
                    alignment: .leading
                )
            }

            if showSummary && !summaryItems.isEmpty {
                DiffSummaryView(items: summaryItems, isVisible: $showSummary)
            }
        }
        .background(AppTheme.background)
    }
}

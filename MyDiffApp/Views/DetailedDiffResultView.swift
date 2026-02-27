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
    @State private var scrollPosition: Int? = nil

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
                        scrollPosition: $scrollPosition
                    )
                    .background(AppTheme.background)
                }

                // Right pane (border-left via overlay)
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
                        scrollPosition: $scrollPosition
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

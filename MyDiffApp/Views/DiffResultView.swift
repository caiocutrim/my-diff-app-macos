//
//  DiffResultView.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI

/// Legacy line-level diff view (kept for compatibility, not used in main flow)
struct DiffResultView: View {
    let diffResult: DiffResult
    @State private var scrollPosition: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                LegendItem(color: AppTheme.addText, label: "Adicionado")
                LegendItem(color: AppTheme.delText, label: "Removido")
                LegendItem(color: AppTheme.modText, label: "Modificado")
            }
            .padding(.vertical, 8)
            .background(AppTheme.surface)

            Divider()

            HSplitView {
                VStack(spacing: 0) {
                    Text("Original (Esquerda)")
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.surface2)

                    Divider()

                    DiffPaneView(
                        lines: diffResult.lines,
                        showLeft: true,
                        scrollPosition: $scrollPosition
                    )
                }

                VStack(spacing: 0) {
                    Text("Comparado (Direita)")
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.surface2)

                    Divider()

                    DiffPaneView(
                        lines: diffResult.lines,
                        showLeft: false,
                        scrollPosition: $scrollPosition
                    )
                }
            }
        }
    }
}

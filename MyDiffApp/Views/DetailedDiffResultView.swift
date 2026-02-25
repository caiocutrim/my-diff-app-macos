//
//  DetailedDiffResultView.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI

struct DetailedDiffResultView: View {
    let detailedLines: [DetailedDiffLine]
    @State private var scrollPosition: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Legenda com tema Dracula
            HStack(spacing: 20) {
                LegendItem(color: DraculaTheme.diffAdded, label: "Adicionado")
                LegendItem(color: DraculaTheme.diffRemoved, label: "Removido")
                LegendItem(color: DraculaTheme.diffModified, label: "Modificado")

                Spacer()

                // Info sobre syntax highlighting
                HStack(spacing: 8) {
                    Image(systemName: "paintbrush.fill")
                        .font(.caption)
                        .foregroundColor(DraculaTheme.pink)
                    Text("Dracula Theme • Syntax Highlighting Ativo")
                        .font(.caption)
                        .foregroundColor(DraculaTheme.foreground)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(DraculaTheme.currentLine)

            Divider()

            // Painéis lado a lado com tema Dracula
            HSplitView {
                VStack(spacing: 0) {
                    HStack {
                        Text("Original (Esquerda)")
                            .font(.headline)
                            .foregroundColor(DraculaTheme.foreground)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(DraculaTheme.currentLine)

                    Divider()

                    DetailedDiffPaneView(
                        lines: detailedLines,
                        showLeft: true,
                        scrollPosition: $scrollPosition
                    )
                    .background(DraculaTheme.background)
                }

                VStack(spacing: 0) {
                    HStack {
                        Text("Comparado (Direita)")
                            .font(.headline)
                            .foregroundColor(DraculaTheme.foreground)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(DraculaTheme.currentLine)

                    Divider()

                    DetailedDiffPaneView(
                        lines: detailedLines,
                        showLeft: false,
                        scrollPosition: $scrollPosition
                    )
                    .background(DraculaTheme.background)
                }
            }
        }
        .background(DraculaTheme.background)
    }
}

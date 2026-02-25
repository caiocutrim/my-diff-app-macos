//
//  DiffResultView.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI

struct DiffResultView: View {
    let diffResult: DiffResult
    @State private var scrollPosition: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Legenda
            HStack(spacing: 20) {
                LegendItem(color: .green.opacity(0.2), label: "Adicionado")
                LegendItem(color: .red.opacity(0.2), label: "Removido")
                LegendItem(color: .yellow.opacity(0.2), label: "Modificado")
            }
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Painéis lado a lado
            HSplitView {
                VStack(spacing: 0) {
                    Text("Original (Esquerda)")
                        .font(.headline)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity)
                        .background(Color(NSColor.controlBackgroundColor))

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
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity)
                        .background(Color(NSColor.controlBackgroundColor))

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

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(color)
                .frame(width: 20, height: 12)
                .cornerRadius(2)

            Text(label)
                .font(.caption)
        }
    }
}

//
//  DiffPaneView.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI

struct DiffPaneView: View {
    let lines: [DiffLine]
    let showLeft: Bool
    @Binding var scrollPosition: Int?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(lines) { line in
                        HStack(alignment: .top, spacing: 8) {
                            // Número da linha
                            Text("\(line.lineNumber)")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 40, alignment: .trailing)

                            // Conteúdo da linha
                            Text(showLeft ? (line.leftContent ?? "") : (line.rightContent ?? ""))
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                        }
                        .background(backgroundColor(for: line.type))
                        .id(line.lineNumber)
                    }
                }
                .padding()
            }
            .onChange(of: scrollPosition) { newValue in
                if let position = newValue {
                    withAnimation {
                        proxy.scrollTo(position, anchor: .top)
                    }
                }
            }
        }
    }

    private func backgroundColor(for type: DiffLineType) -> Color {
        switch type {
        case .equal:
            return Color.clear
        case .added:
            return Color.green.opacity(0.2)
        case .removed:
            return Color.red.opacity(0.2)
        case .modified:
            return Color.yellow.opacity(0.2)
        }
    }
}

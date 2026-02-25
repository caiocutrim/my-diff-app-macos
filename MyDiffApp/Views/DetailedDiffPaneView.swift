//
//  DetailedDiffPaneView.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI

struct DetailedDiffPaneView: View {
    let lines: [DetailedDiffLine]
    let showLeft: Bool
    @Binding var scrollPosition: Int?
    @ObservedObject var fontSettings = FontSettings.shared

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(lines) { line in
                        HStack(alignment: .top, spacing: 8) {
                            // Número da linha
                            Text("\(line.lineNumber)")
                                .font(.system(size: CGFloat(fontSettings.fontSize) * 0.85, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 40, alignment: .trailing)
                                .padding(.top, 4)

                            // Conteúdo da linha com syntax highlighting Dracula
                            let segments = showLeft ? line.leftSegments : line.rightSegments
                            if segments.isEmpty {
                                Text("")
                                    .frame(height: 20)
                            } else {
                                Text(JSONSyntaxHighlighter.highlightSegments(segments, theme: .dracula, fontSize: CGFloat(fontSettings.fontSize)))
                                    .font(fontSettings.swiftUIMonospacedFont)
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 4)
                            }
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
            return DraculaTheme.background
        case .added:
            return DraculaTheme.diffAdded.opacity(0.15)
        case .removed:
            return DraculaTheme.diffRemoved.opacity(0.15)
        case .modified:
            return DraculaTheme.diffModified.opacity(0.15)
        }
    }
}

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
                        DiffLineRowView(
                            line: line,
                            showLeft: showLeft,
                            fontSize: CGFloat(fontSettings.fontSize)
                        )
                        .id(line.lineNumber)
                    }
                }
                .padding(.vertical, 12)
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
}

struct DiffLineRowView: View {
    let line: DetailedDiffLine
    let showLeft: Bool
    let fontSize: CGFloat

    private var lineType: DiffLineType { line.type }

    private var borderColor: Color {
        switch lineType {
        case .added: return AppTheme.addLine
        case .removed: return AppTheme.delLine
        case .modified: return AppTheme.modLine
        case .equal: return .clear
        }
    }

    private var bgColor: Color {
        switch lineType {
        case .added: return AppTheme.addBg
        case .removed: return AppTheme.delBg
        case .modified: return AppTheme.modBg
        case .equal: return .clear
        }
    }

    private var gutterBgColor: Color {
        switch lineType {
        case .added: return AppTheme.addGutter
        case .removed: return AppTheme.delGutter
        case .modified: return AppTheme.modGutter
        case .equal: return .clear
        }
    }

    private var gutterTextColor: Color {
        switch lineType {
        case .added: return AppTheme.addText
        case .removed: return AppTheme.delText
        case .modified: return AppTheme.modText
        case .equal: return AppTheme.textDim
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left border indicator (2px)
            if lineType != .equal {
                Rectangle()
                    .fill(borderColor)
                    .frame(width: 2)
            }

            // Line number gutter
            Text("\(line.lineNumber)")
                .font(.system(size: fontSize * 0.85, design: .monospaced))
                .foregroundColor(gutterTextColor)
                .frame(width: 40, alignment: .trailing)
                .padding(.horizontal, 8)
                .frame(minHeight: 22)
                .background(gutterBgColor)

            // Content
            let segments = showLeft ? line.leftSegments : line.rightSegments
            if segments.isEmpty {
                Text("")
                    .frame(height: 22)
            } else {
                // Only apply inline character highlights for modified lines;
                // added/removed lines already have the line-level background color.
                Text(JSONSyntaxHighlighter.highlightSegments(
                    segments,
                    theme: .material,
                    fontSize: fontSize,
                    inlineHighlight: lineType == .modified
                ))
                    .font(.system(size: fontSize, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .frame(minHeight: 22)
            }
        }
        .background(bgColor)
    }
}

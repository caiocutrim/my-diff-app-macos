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
    @Binding var scrollTarget: UUID?
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
                        .id(line.id)
                    }
                }
                .padding(.vertical, 12)
            }
            .onChange(of: scrollTarget) { target in
                if let id = target {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        proxy.scrollTo(id, anchor: .top)
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

    // Gutter & border colors per type
    private var borderColor: Color {
        switch lineType {
        case .added:    return AppTheme.addLine
        case .removed:  return AppTheme.delLine
        case .modified: return AppTheme.modLine
        case .equal:    return .clear
        }
    }

    private var bgColor: Color {
        switch lineType {
        case .added:    return AppTheme.addBg
        case .removed:  return AppTheme.delBg
        case .modified: return AppTheme.modBg
        case .equal:    return .clear
        }
    }

    private var gutterBg: Color {
        switch lineType {
        case .added:    return AppTheme.addGutter
        case .removed:  return AppTheme.delGutter
        case .modified: return AppTheme.modGutter
        case .equal:    return .clear
        }
    }

    private var gutterFg: Color {
        switch lineType {
        case .added:    return AppTheme.addText
        case .removed:  return AppTheme.delText
        case .modified: return AppTheme.modText
        case .equal:    return AppTheme.textDim
        }
    }

    /// Line number to show for this pane (nil = placeholder gutter)
    private var lineNumber: Int? {
        showLeft ? line.leftLineNumber : line.rightLineNumber
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // 2px left border for non-equal lines
            if lineType != .equal {
                Rectangle()
                    .fill(borderColor)
                    .frame(width: 2)
            }

            // Gutter — number when the line exists on this side, blank otherwise
            Group {
                if let num = lineNumber {
                    Text("\(num)")
                        .foregroundColor(gutterFg)
                } else {
                    // Placeholder: line exists on the other side only
                    Text(" ")
                }
            }
            .font(.system(size: fontSize * 0.85, design: .monospaced))
            .frame(width: 40, alignment: .trailing)
            .padding(.horizontal, 8)
            .frame(minHeight: 22)
            .background(gutterBg)

            // Content
            let segments = showLeft ? line.leftSegments : line.rightSegments
            if segments.isEmpty {
                // Empty placeholder row (line only exists on the other side)
                Text(" ")
                    .font(.system(size: fontSize, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .frame(minHeight: 22)
            } else {
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

//
//  DetailedDiffPaneView.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI

// MARK: - Highlight request

/// Wraps a lineID + a nonce so .onChange fires even when the same line is clicked twice.
struct HighlightRequest: Equatable {
    let lineID: UUID
    let nonce  = UUID()
}

// MARK: - Pane

struct DetailedDiffPaneView: View {
    let lines: [DetailedDiffLine]
    let showLeft: Bool
    @Binding var scrollTarget: UUID?
    var highlightRequest: HighlightRequest? = nil
    @ObservedObject var fontSettings = FontSettings.shared

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(lines) { line in
                        DiffLineRowView(
                            line: line,
                            showLeft: showLeft,
                            fontSize: CGFloat(fontSettings.fontSize),
                            highlightRequest: highlightRequest
                        )
                        .id(line.id)
                    }
                }
                .padding(.vertical, 12)
            }
            .onChange(of: scrollTarget) { target in
                if let id = target {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
    }
}

// MARK: - Row

struct DiffLineRowView: View {
    let line: DetailedDiffLine
    let showLeft: Bool
    let fontSize: CGFloat
    var highlightRequest: HighlightRequest? = nil

    @State private var flashOpacity: Double = 0

    private var lineType: DiffLineType { line.type }

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

            // Gutter
            Group {
                if let num = lineNumber {
                    Text("\(num)").foregroundColor(gutterFg)
                } else {
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
        // Flash overlay — white pulse when this row is the scroll target
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(flashOpacity))
                .allowsHitTesting(false)
        )
        .onChange(of: highlightRequest) { req in
            guard req?.lineID == line.id else { return }
            triggerFlash()
        }
    }

    private func triggerFlash() {
        flashOpacity = 0
        // Fase 1 — fade in rápido
        withAnimation(.easeIn(duration: 0.18)) {
            flashOpacity = 0.30
        }
        // Fase 2 — fade out lento após o pico
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.easeOut(duration: 1.1)) {
                flashOpacity = 0
            }
        }
    }
}

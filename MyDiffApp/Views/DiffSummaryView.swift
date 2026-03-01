//
//  DiffSummaryView.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI

struct DiffSummaryView: View {
    let items: [DiffSummaryItem]
    @Binding var isVisible: Bool
    var onScrollTo: (UUID) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)

            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textMuted)

                    Text("Resumo das Diferenças")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.textMuted)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    // Count badge
                    Text("\(items.count)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.modText)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 1)
                        .background(AppTheme.modGutter)
                        .overlay(
                            RoundedRectangle(cornerRadius: 99)
                                .stroke(AppTheme.modLine, lineWidth: 1)
                        )
                        .cornerRadius(99)
                }

                Spacer()

                Button(action: { isVisible = false }) {
                    Text("\u{2715}")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textMuted)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .help("Fechar resumo")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(AppTheme.borderSubtle),
                alignment: .bottom
            )

            // Items list
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(items) { item in
                        SummaryItemRow(item: item, onTap: { onScrollTo(item.lineID) })
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .padding(.bottom, 4)
            }
            .frame(maxHeight: 180)
        }
        .background(AppTheme.surface)
    }
}

struct SummaryItemRow: View {
    let item: DiffSummaryItem
    var onTap: () -> Void = {}
    @State private var isHovered = false

    private var chipColor: Color {
        switch item.changeType {
        case .added: return AppTheme.addText
        case .removed: return AppTheme.delText
        case .modified: return AppTheme.modText
        }
    }

    private var chipBg: Color {
        switch item.changeType {
        case .added: return AppTheme.addGutter
        case .removed: return AppTheme.delGutter
        case .modified: return AppTheme.modGutter
        }
    }

    private var chipBorder: Color {
        switch item.changeType {
        case .added: return AppTheme.addLine
        case .removed: return AppTheme.delLine
        case .modified: return AppTheme.modLine
        }
    }

    private var chipLabel: String {
        switch item.changeType {
        case .added: return "Adicionado"
        case .removed: return "Removido"
        case .modified: return "Modificado"
        }
    }

    private var iconText: String {
        switch item.changeType {
        case .added: return "\u{2795}"
        case .removed: return "\u{2796}"
        case .modified: return "\u{21C4}"
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            // Icon
            Text(iconText)
                .font(.system(size: 12))
                .opacity(0.8)

            // Field name
            Text(item.fieldName)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(AppTheme.text)

            Spacer()

            // Values — only show what's available
            switch item.changeType {
            case .modified:
                HStack(spacing: 6) {
                    if let old = item.oldValue {
                        Text(old)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(AppTheme.delText)
                            .lineLimit(1)
                    }
                    Text("\u{2192}")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textDim)
                    if let new = item.newValue {
                        Text(new)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(AppTheme.addText)
                            .lineLimit(1)
                    }
                }
            case .removed:
                if let old = item.oldValue {
                    Text(old)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(AppTheme.delText)
                        .lineLimit(1)
                }
            case .added:
                if let new = item.newValue {
                    Text(new)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(AppTheme.addText)
                        .lineLimit(1)
                }
            }

            // Chip badge
            Text(chipLabel)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(chipColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(chipBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 99)
                        .stroke(chipBorder, lineWidth: 1)
                )
                .cornerRadius(99)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(isHovered ? AppTheme.surface2.opacity(1.6) : AppTheme.surface2)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusSm)
                .stroke(isHovered ? AppTheme.border : AppTheme.borderSubtle, lineWidth: 1)
        )
        .cornerRadius(AppTheme.radiusSm)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .onHover { hovering in
            isHovered = hovering
            if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
        }
    }
}

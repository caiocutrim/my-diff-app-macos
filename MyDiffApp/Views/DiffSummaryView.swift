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
                        SummaryItemRow(item: item)
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

            // Values
            if item.changeType == .modified {
                HStack(spacing: 6) {
                    Text(item.oldValue ?? "")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(AppTheme.delText)
                    Text("\u{2192}")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textDim)
                    Text(item.newValue ?? "")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(AppTheme.addText)
                }
            } else if item.changeType == .removed {
                Text(item.oldValue ?? "")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(AppTheme.delText)
            } else {
                Text(item.newValue ?? "")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(AppTheme.addText)
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
        .background(AppTheme.surface2)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusSm)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
        .cornerRadius(AppTheme.radiusSm)
    }
}

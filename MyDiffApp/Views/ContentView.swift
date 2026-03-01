//
//  ContentView.swift
//  MyDiffApp
//
//  Created by Claude Code
//

import SwiftUI

struct ContentView: View {
    @State private var leftJSON: String = ""
    @State private var rightJSON: String = ""
    @State private var detailedDiffLines: [DetailedDiffLine]?
    @State private var leftError: JSONError? = nil
    @State private var rightError: JSONError? = nil
    @State private var pendingFormattedLeft: String? = nil
    @State private var pendingFormattedRight: String? = nil
    @State private var showSummary = true
    @ObservedObject var fontSettings = FontSettings.shared

    private var diffCount: Int {
        detailedDiffLines?.filter { $0.type != .equal }.count ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            if detailedDiffLines != nil {
                comparisonToolbar
            } else {
                editingToolbar
            }

            if let lines = detailedDiffLines {
                DetailedDiffResultView(
                    detailedLines: lines,
                    showSummary: $showSummary
                )
                .background(AppTheme.background)
            } else {
                editingPanels
            }

            hiddenFontControls
        }
    }

    // MARK: - Comparison Mode Toolbar

    private var comparisonToolbar: some View {
        HStack(spacing: 8) {
            Text("JsonDiffApp")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.text)

            ToolbarDivider()

            // Legend dots
            HStack(spacing: 14) {
                LegendItem(color: AppTheme.addText, label: "Adicionado")
                LegendItem(color: AppTheme.delText, label: "Removido")
                LegendItem(color: AppTheme.modText, label: "Modificado")
            }

            Spacer()

            HStack(spacing: 8) {
                // Compare button
                Button(action: { compareJSON() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 11))
                        Text("Comparar")
                    }
                }
                .buttonStyle(GhostButtonStyle(isPrimary: true))
                .keyboardShortcut("r", modifiers: .command)

                // Back to edit
                Button(action: { detailedDiffLines = nil; showSummary = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 11))
                        Text("Voltar para Edição")
                    }
                }
                .buttonStyle(GhostButtonStyle())

                // Diff count badge
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text("\(diffCount) diferença\(diffCount == 1 ? "" : "s") encontrada\(diffCount == 1 ? "" : "s")")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.modText)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppTheme.modGutter)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusSm)
                        .stroke(AppTheme.modLine, lineWidth: 1)
                )
                .cornerRadius(AppTheme.radiusSm)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppTheme.surface)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppTheme.border),
            alignment: .bottom
        )
    }

    // MARK: - Editing Mode Toolbar

    private var editingToolbar: some View {
        HStack(spacing: 8) {
            Text("JsonDiffApp")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.text)

            ToolbarDivider()

            Text("Compare JSONs lado a lado")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textMuted)

            Spacer()

            HStack(spacing: 8) {
                Button(action: { formatJSON() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 11))
                        Text("Formatar")
                    }
                }
                .buttonStyle(GhostButtonStyle())

                Button(action: { clearAll() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11))
                        Text("Limpar")
                    }
                }
                .buttonStyle(GhostButtonStyle())
                .keyboardShortcut("k", modifiers: .command)

                Button(action: { compareJSON() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 11))
                        Text("Comparar")
                    }
                }
                .buttonStyle(GhostButtonStyle(isPrimary: true))
                .keyboardShortcut("r", modifiers: .command)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppTheme.surface)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppTheme.border),
            alignment: .bottom
        )
    }

    // MARK: - Editing Panels

    private var editingPanels: some View {
        HSplitView {
            VStack(spacing: 0) {
                PaneHeaderView(
                    icon: "doc.text",
                    title: "Original",
                    subtitle: "(Esquerda)",
                    filename: "original.json"
                )
                if let err = leftError {
                    ErrorBannerView(error: err)
                }
                JSONTextEditor(
                    text: $leftJSON,
                    placeholder: "Cole o JSON original aqui...",
                    errorLocation: leftError?.location
                )
            }
            .background(AppTheme.background)
            .onChange(of: leftJSON) { _ in leftError = nil }

            VStack(spacing: 0) {
                PaneHeaderView(
                    icon: "doc.on.clipboard",
                    title: "Comparado",
                    subtitle: "(Direita)",
                    filename: "comparado.json"
                )
                if let err = rightError {
                    ErrorBannerView(error: err)
                }
                JSONTextEditor(
                    text: $rightJSON,
                    placeholder: "Cole o JSON para comparar aqui...",
                    errorLocation: rightError?.location
                )
            }
            .background(AppTheme.background)
            .onChange(of: rightJSON) { _ in rightError = nil }
        }
        .background(AppTheme.background)
    }

    // MARK: - Hidden Font Controls

    private var hiddenFontControls: some View {
        HStack(spacing: 0) {
            Button(action: { fontSettings.decrease() }) { EmptyView() }
                .keyboardShortcut("-", modifiers: .command)
                .frame(width: 0, height: 0)
                .opacity(0)

            Button(action: { fontSettings.increase() }) { EmptyView() }
                .keyboardShortcut("+", modifiers: .command)
                .frame(width: 0, height: 0)
                .opacity(0)

            Button(action: { fontSettings.reset() }) { EmptyView() }
                .keyboardShortcut("0", modifiers: .command)
                .frame(width: 0, height: 0)
                .opacity(0)
        }
    }

    // MARK: - Actions

    private func compareJSON() {
        let leftResult  = JSONFormatter.format(jsonString: leftJSON)
        let rightResult = JSONFormatter.format(jsonString: rightJSON)

        var formattedLeft: String
        var formattedRight: String

        switch leftResult {
        case .success(let formatted):
            formattedLeft = formatted
            leftError = nil
        case .failure(let error):
            leftError = error
            return
        }

        switch rightResult {
        case .success(let formatted):
            formattedRight = formatted
            rightError = nil
        case .failure(let error):
            rightError = error
            return
        }

        // Structure check — present native NSAlert with warning icon
        if let warning = JSONStructureAnalyzer.analyze(left: formattedLeft, right: formattedRight) {
            pendingFormattedLeft  = formattedLeft
            pendingFormattedRight = formattedRight
            presentStructureWarning(message: warning.message)
            return
        }

        runDiff(left: formattedLeft, right: formattedRight)
    }

    private func presentStructureWarning(message: String) {
        let alert = NSAlert()
        alert.messageText     = "Estruturas muito diferentes"
        alert.informativeText = message
        alert.alertStyle      = .warning
        alert.icon            = NSImage(named: NSImage.cautionName)
        alert.addButton(withTitle: "Comparar assim mesmo")
        alert.addButton(withTitle: "Cancelar")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn,
           let l = pendingFormattedLeft,
           let r = pendingFormattedRight {
            runDiff(left: l, right: r)
        }
        pendingFormattedLeft  = nil
        pendingFormattedRight = nil
    }

    private func runDiff(left: String, right: String) {
        detailedDiffLines = DiffEngine.compareDetailed(left: left, right: right)
        showSummary = true
    }

    private func clearAll() {
        leftJSON = ""
        rightJSON = ""
        detailedDiffLines     = nil
        leftError             = nil
        rightError            = nil
        pendingFormattedLeft  = nil
        pendingFormattedRight = nil
    }

    private func formatJSON() {
        if !leftJSON.isEmpty {
            switch JSONFormatter.format(jsonString: leftJSON) {
            case .success(let formatted):
                leftJSON   = formatted
                leftError  = nil
            case .failure(let error):
                leftError = error
                return
            }
        }

        if !rightJSON.isEmpty {
            switch JSONFormatter.format(jsonString: rightJSON) {
            case .success(let formatted):
                rightJSON  = formatted
                rightError = nil
            case .failure(let error):
                rightError = error
                return
            }
        }
    }
}

// MARK: - Reusable Components

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textMuted)
        }
    }
}

struct ToolbarDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.border)
            .frame(width: 1, height: 20)
            .padding(.horizontal, 4)
    }
}

struct PaneHeaderView: View {
    let icon: String
    let title: String
    let subtitle: String
    let filename: String

    var body: some View {
        HStack {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textMuted)
                    .opacity(0.7)
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textDim)
            }
            Spacer()
            Text(filename)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(AppTheme.textDim)
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 14)
        .background(AppTheme.surface2)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppTheme.borderSubtle),
            alignment: .bottom
        )
    }
}

struct GhostButtonStyle: ButtonStyle {
    var isPrimary = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .foregroundColor(isPrimary ? Color(hex: "#0d1117") : AppTheme.textMuted)
            .background(isPrimary ? AppTheme.accent : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusSm)
                    .stroke(isPrimary ? AppTheme.accent : AppTheme.border, lineWidth: 1)
            )
            .cornerRadius(AppTheme.radiusSm)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct ErrorBannerView: View {
    let error: JSONError

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.delText)
            Text(error.localizedDescription)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(AppTheme.delText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(AppTheme.delBg)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppTheme.delLine),
            alignment: .bottom
        )
    }
}

#Preview {
    ContentView()
        .frame(width: 900, height: 600)
}

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
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @ObservedObject var fontSettings = FontSettings.shared

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar com tema Dracula e controle de fonte
            HStack {
                Button("Comparar") {
                    compareJSON()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut("r", modifiers: .command)

                Button("Limpar") {
                    clearAll()
                }
                .keyboardShortcut("k", modifiers: .command)

                Button("Formatar") {
                    formatJSON()
                }

                Divider()
                    .frame(height: 20)
                    .padding(.horizontal, 4)

                // Controle de tamanho de fonte
                HStack(spacing: 8) {
                    Button(action: { fontSettings.decrease() }) {
                        Image(systemName: "textformat.size.smaller")
                    }
                    .help("Diminuir fonte (⌘-)")
                    .keyboardShortcut("-", modifiers: .command)

                    Text("\(Int(fontSettings.fontSize))pt")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(DraculaTheme.foreground)
                        .frame(width: 35)

                    Button(action: { fontSettings.increase() }) {
                        Image(systemName: "textformat.size.larger")
                    }
                    .help("Aumentar fonte (⌘+)")
                    .keyboardShortcut("+", modifiers: .command)

                    Button(action: { fontSettings.reset() }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .help("Resetar tamanho (⌘0)")
                    .keyboardShortcut("0", modifiers: .command)
                }
            }
            .padding()
            .background(DraculaTheme.currentLine)

            Divider()

            if let lines = detailedDiffLines {
                // Mostrar resultado do diff com syntax highlighting Dracula
                DetailedDiffResultView(detailedLines: lines)
                    .background(DraculaTheme.background)
            } else {
                // Mostrar campos de entrada com syntax highlighting em tempo real
                HSplitView {
                    VStack(spacing: 0) {
                        HStack {
                            Text("JSON Original (Esquerda)")
                                .font(.headline)
                                .foregroundColor(DraculaTheme.foreground)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(DraculaTheme.currentLine)

                        Divider()

                        JSONTextEditor(text: $leftJSON, placeholder: "Cole seu JSON aqui...")
                    }
                    .background(DraculaTheme.background)

                    VStack(spacing: 0) {
                        HStack {
                            Text("JSON para Comparar (Direita)")
                                .font(.headline)
                                .foregroundColor(DraculaTheme.foreground)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(DraculaTheme.currentLine)

                        Divider()

                        JSONTextEditor(text: $rightJSON, placeholder: "Cole seu JSON aqui...")
                    }
                    .background(DraculaTheme.background)
                }
                .background(DraculaTheme.background)
            }
        }
        .alert("Erro", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func compareJSON() {
        // Formatar ambos os JSONs
        let leftResult = JSONFormatter.format(jsonString: leftJSON)
        let rightResult = JSONFormatter.format(jsonString: rightJSON)

        var formattedLeft: String
        var formattedRight: String

        // Validar e obter JSON formatado do lado esquerdo
        switch leftResult {
        case .success(let formatted):
            formattedLeft = formatted
        case .failure(let error):
            alertMessage = "Erro no JSON da esquerda: \(error.localizedDescription)"
            showingAlert = true
            return
        }

        // Validar e obter JSON formatado do lado direito
        switch rightResult {
        case .success(let formatted):
            formattedRight = formatted
        case .failure(let error):
            alertMessage = "Erro no JSON da direita: \(error.localizedDescription)"
            showingAlert = true
            return
        }

        // Executar diff com character-level e syntax highlighting
        detailedDiffLines = DiffEngine.compareDetailed(left: formattedLeft, right: formattedRight)
    }

    private func clearAll() {
        leftJSON = ""
        rightJSON = ""
        detailedDiffLines = nil
    }

    private func formatJSON() {
        // Formatar JSON da esquerda
        if !leftJSON.isEmpty {
            switch JSONFormatter.format(jsonString: leftJSON) {
            case .success(let formatted):
                leftJSON = formatted
            case .failure(let error):
                alertMessage = "Erro ao formatar JSON da esquerda: \(error.localizedDescription)"
                showingAlert = true
                return
            }
        }

        // Formatar JSON da direita
        if !rightJSON.isEmpty {
            switch JSONFormatter.format(jsonString: rightJSON) {
            case .success(let formatted):
                rightJSON = formatted
            case .failure(let error):
                alertMessage = "Erro ao formatar JSON da direita: \(error.localizedDescription)"
                showingAlert = true
                return
            }
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 900, height: 600)
}

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ImportView: View {
    @ObservedObject var sessionManager: SessionManager
    @State private var inputText: String = ""
    @State private var isTargeted: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            TextEditor(text: $inputText)
                .font(.body)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isTargeted ? Color.blue : Color.gray.opacity(0.2), lineWidth: isTargeted ? 2 : 1))
                .onDrop(of: [.plainText, .fileURL], isTargeted: $isTargeted) { providers in
                    handleDrop(providers: providers)
                }

            HStack {
                Button("Select File") {
                    selectFile()
                }

                Button("Import Text") {
                    sessionManager.importText(inputText)
                }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
                    guard let data = item as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil),
                          let text = try? String(contentsOf: url) else { return }
                    DispatchQueue.main.async {
                        self.inputText = text
                    }
                }
                return true
            } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (item, error) in
                    if let string = item as? String {
                        DispatchQueue.main.async {
                            self.inputText = string
                        }
                    } else if let data = item as? Data,
                              let string = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self.inputText = string
                        }
                    }
                }
                return true
            }
        }
        return false
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.plainText, .text]

        if panel.runModal() == .OK {
            if let url = panel.url, let text = try? String(contentsOf: url) {
                inputText = text
            }
        }
    }
}

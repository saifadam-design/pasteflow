import SwiftUI

struct ImportView: View {
    @ObservedObject var sessionManager: SessionManager
    @State private var inputText: String = ""

    var body: some View {
        VStack {
            TextEditor(text: $inputText)
                .font(.body)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))

            Button("Import Text") {
                sessionManager.importText(inputText)
            }
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}

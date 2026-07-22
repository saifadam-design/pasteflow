import Foundation
import Combine

class SessionManager: ObservableObject {
    @Published var chunks: [String] = []
    @Published var currentIndex: Int = 0
    @Published var splitMode: SplitMode = .word

    let pasteManager = PasteManager()

    var currentChunk: String? {
        guard currentIndex < chunks.count else { return nil }
        return chunks[currentIndex]
    }

    var progress: Double {
        guard !chunks.isEmpty else { return 0 }
        return Double(currentIndex) / Double(chunks.count)
    }

    func importText(_ text: String) {
        switch splitMode {
        case .word:
            // Use split to handle multiple spaces/newlines cleanly
            chunks = text.split { $0.isWhitespace || $0.isNewline }.map(String.init)
        case .sentence:
            chunks = text.components(separatedBy: ".").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            // Add periods back since components(separatedBy:) removes them
            chunks = chunks.map { $0 + "." }
        case .paragraph:
            chunks = text.components(separatedBy: "\n\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        case .character:
            chunks = text.map { String($0) }
        }
        currentIndex = 0
        Logger.shared.log("Text imported and split by \(splitMode.rawValue). Total chunks: \(chunks.count)")
    }

    func pasteNext() {
        guard let chunk = currentChunk else { return }
        Logger.shared.log("Pasting chunk: \(chunk)")
        pasteManager.paste(text: chunk) {
            DispatchQueue.main.async {
                self.currentIndex += 1
                Logger.shared.log("Chunk advanced. Progress: \(self.currentIndex)/\(self.chunks.count)")
            }
        }
    }

    func skip() {
        if currentIndex < chunks.count {
            currentIndex += 1
            Logger.shared.log("Skipped chunk")
        }
    }

    func restart() {
        currentIndex = 0
        Logger.shared.log("Session restarted")
    }

    func clear() {
        chunks = []
        currentIndex = 0
        Logger.shared.log("Session cleared")
    }
}

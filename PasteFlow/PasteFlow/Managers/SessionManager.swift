import Foundation
import Combine

@MainActor
class SessionManager: ObservableObject {
    @Published var session = Session()

    let pasteManager = PasteManager()

    func importText(_ text: String) {
        var newChunks: [String] = []

        switch session.mode {
        case .word:
            newChunks = text.split { $0.isWhitespace || $0.isNewline }.map(String.init)
        case .sentence:
            newChunks = text.components(separatedBy: ".").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }.map { $0 + "." }
        case .paragraph:
            newChunks = text.components(separatedBy: "\n\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        case .character:
            newChunks = text.map { String($0) }
        }

        session.chunks = newChunks.map { Chunk(text: $0) }
        session.currentIndex = 0
        Logger.shared.log("Text imported and split by \(session.mode.rawValue). Total chunks: \(session.chunks.count)")
    }

    func pasteNext() {
        guard let chunk = session.currentChunk else { return }
        Logger.shared.log("Pasting chunk: \(chunk.text)")

        Task {
            await pasteManager.paste(text: chunk.text)
            self.session.currentIndex += 1
            Logger.shared.log("Chunk advanced. Progress: \(self.session.currentIndex)/\(self.session.chunks.count)")
        }
    }

    func skip() {
        if session.currentIndex < session.chunks.count {
            session.currentIndex += 1
            Logger.shared.log("Skipped chunk")
        }
    }

    func restart() {
        session.currentIndex = 0
        Logger.shared.log("Session restarted")
    }

    func clear() {
        session.chunks = []
        session.currentIndex = 0
        Logger.shared.log("Session cleared")
    }
}

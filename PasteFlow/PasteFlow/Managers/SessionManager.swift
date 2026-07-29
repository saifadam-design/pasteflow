import Foundation
import Combine
import NaturalLanguage

@MainActor
class SessionManager: ObservableObject {
    @Published var session = Session()

    let pasteManager = PasteManager()

    func importText(_ text: String) {
        session.originalText = text
        var newChunks: [String] = []

        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text

        switch session.mode {
        case .word:
            tokenizer.unit = .word
            tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
                newChunks.append(String(text[tokenRange]))
                return true
            }
        case .sentence:
            tokenizer.unit = .sentence
            tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
                let sentence = String(text[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !sentence.isEmpty {
                    newChunks.append(sentence)
                }
                return true
            }
        case .paragraph:
            tokenizer.unit = .paragraph
            tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
                let paragraph = String(text[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !paragraph.isEmpty {
                    newChunks.append(paragraph)
                }
                return true
            }
        case .character:
            newChunks = text.map { String($0) }
        }

        session.chunks = newChunks.map { Chunk(text: $0) }
        session.currentIndex = 0
        Logger.shared.log("Text imported and split by \(session.mode.rawValue). Total chunks: \(session.chunks.count)")
    }

    func rebuildSession() {
        if !session.originalText.isEmpty {
            importText(session.originalText)
        }
    }

    func pasteNext() {
        guard let chunk = session.currentChunk else { return }
        Logger.shared.log("Pasting chunk")

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
        session.originalText = ""
        Logger.shared.log("Session cleared")
    }
}

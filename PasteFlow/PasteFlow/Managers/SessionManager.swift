import Foundation
import Combine
import NaturalLanguage

@MainActor
class SessionManager: ObservableObject {
    @Published var session = Session()
    weak var clipboardMonitor: ClipboardMonitor?

    let pasteManager = PasteManager()
    private var settingsChangeCancellable: AnyCancellable?

    init() {
        settingsChangeCancellable = SettingsManager.shared.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }

    var currentFormattedChunkText: String? {
        session.currentChunk.map { formattedText(for: $0.text) }
    }

    var formattingPreviewOriginalText: String {
        session.currentChunk?.text ?? "hello"
    }

    var formattingPreviewOutputText: String {
        formattedText(for: formattingPreviewOriginalText)
    }

    func importText(_ text: String) {
        session.originalText = text
        session.chunks = splitText(text, mode: session.mode).map { Chunk(text: $0) }
        session.currentIndex = 0
        Logger.shared.log("Text imported and split by \(session.mode.rawValue). Total chunks: \(session.chunks.count)")
    }

    func rebuildSession() {
        if !session.originalText.isEmpty {
            importText(session.originalText)
        }
    }

    func pasteNext() {
        guard let chunkText = currentFormattedChunkText else { return }
        Logger.shared.log("Pasting chunk")

        Task {
            self.clipboardMonitor?.beginAppPasteTransaction()
            defer { self.clipboardMonitor?.endAppPasteTransaction() }

            await pasteManager.paste(text: chunkText)
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

    func formattedText(for text: String) -> String {
        let settings = SettingsManager.shared
        var formattedText = ""

        if settings.enablePrefix {
            formattedText += settings.prefixText
        }

        if settings.prefixSpace {
            formattedText += " "
        }

        formattedText += text

        if settings.enableSuffix {
            formattedText += settings.suffixText
        }

        if settings.suffixSpace {
            formattedText += " "
        }

        return formattedText
    }

    private func splitText(_ text: String, mode: SplitMode) -> [String] {
        var chunks: [String] = []

        switch mode {
        case .word:
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = text
            tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
                chunks.append(String(text[tokenRange]))
                return true
            }
        case .sentence:
            let tokenizer = NLTokenizer(unit: .sentence)
            tokenizer.string = text
            tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
                let sentence = String(text[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !sentence.isEmpty {
                    chunks.append(sentence)
                }
                return true
            }
        case .paragraph:
            let tokenizer = NLTokenizer(unit: .paragraph)
            tokenizer.string = text
            tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
                let paragraph = String(text[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !paragraph.isEmpty {
                    chunks.append(paragraph)
                }
                return true
            }
        case .character:
            chunks = text.map { String($0) }
        }

        return chunks
    }
}

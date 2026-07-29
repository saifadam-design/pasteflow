import Foundation

enum SplitMode: String, CaseIterable, Identifiable, Codable {
    case word = "Word"
    case sentence = "Sentence"
    case paragraph = "Paragraph"
    case character = "Character"

    var id: String { self.rawValue }
}

struct Session {
    var chunks: [Chunk] = []
    var currentIndex: Int = 0
    var mode: SplitMode = .word
    var originalText: String = ""

    var currentChunk: Chunk? {
        guard currentIndex < chunks.count else { return nil }
        return chunks[currentIndex]
    }

    var progress: Double {
        guard !chunks.isEmpty else { return 0 }
        return Double(currentIndex) / Double(chunks.count)
    }
}

import Foundation

enum SplitMode: String, CaseIterable, Identifiable, Codable {
    case word = "Word"
    case sentence = "Sentence"
    case paragraph = "Paragraph"
    case character = "Character"

    var id: String { self.rawValue }
}

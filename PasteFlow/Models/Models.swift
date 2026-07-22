import Foundation

enum SplitMode: String, CaseIterable, Identifiable, Codable {
    case word = "Word"
    case sentence = "Sentence"
    case paragraph = "Paragraph"
    case character = "Character"

    var id: String { self.rawValue }
}

enum ShortcutType: String, CaseIterable, Identifiable, Codable {
    case pasteNext = "Paste Next"
    case restart = "Restart"
    case skip = "Skip"
    case clear = "Clear"

    var id: String { self.rawValue }
}

struct ShortcutInfo: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32
}

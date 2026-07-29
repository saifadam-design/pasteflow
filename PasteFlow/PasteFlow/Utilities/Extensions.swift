import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let pasteNext = Self("pasteNext", default: .init(.v, modifiers: [.command, .option]))
    static let restart = Self("restart", default: .init(.return, modifiers: [.command, .option]))
    static let skip = Self("skip", default: .init(.rightArrow, modifiers: [.command, .option]))
    static let clear = Self("clear", default: .init(.delete, modifiers: [.command, .option]))
}

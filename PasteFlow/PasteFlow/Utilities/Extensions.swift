import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    nonisolated(unsafe) static let pasteNext = Self("pasteNext", default: .init(.v, modifiers: [.command, .option]))
    nonisolated(unsafe) static let restart = Self("restart", default: .init(.return, modifiers: [.command, .option]))
    nonisolated(unsafe) static let skip = Self("skip", default: .init(.rightArrow, modifiers: [.command, .option]))
    nonisolated(unsafe) static let clear = Self("clear", default: .init(.delete, modifiers: [.command, .option]))
}

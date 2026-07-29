import Foundation
import KeyboardShortcuts

@MainActor
class ShortcutManager: ObservableObject {
    static let shared = ShortcutManager()

    var sessionManager: SessionManager?

    private init() {}

    func setup(sessionManager: SessionManager) {
        self.sessionManager = sessionManager

        KeyboardShortcuts.onKeyUp(for: .pasteNext) { [weak self] in
            self?.sessionManager?.pasteNext()
        }

        KeyboardShortcuts.onKeyUp(for: .restart) { [weak self] in
            self?.sessionManager?.restart()
        }

        KeyboardShortcuts.onKeyUp(for: .skip) { [weak self] in
            self?.sessionManager?.skip()
        }

        KeyboardShortcuts.onKeyUp(for: .clear) { [weak self] in
            self?.sessionManager?.clear()
        }
    }
}

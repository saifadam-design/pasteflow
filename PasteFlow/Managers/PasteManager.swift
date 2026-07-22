import Foundation
import AppKit

class PasteManager {
    let clipboardManager = ClipboardManager()

    func paste(text: String, completion: @escaping () -> Void) {
        clipboardManager.saveClipboard()
        clipboardManager.replaceClipboard(with: text)

        // Ensure the clipboard change has time to propagate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.sendCmdV()

            // Allow time for the paste event to be processed by the active app
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.clipboardManager.restoreClipboard()
                completion()
            }
        }
    }

    private func sendCmdV() {
        let vKeyCode: CGKeyCode = 9 // 'v' key
        let commandFlag = CGEventFlags.maskCommand

        let source = CGEventSource(stateID: .hidSystemState)
        let eventDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true)
        let eventUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)

        // Use exactly and only the Command flag to avoid other modifiers bleeding in (e.g. Option)
        eventDown?.flags = commandFlag
        eventUp?.flags = []

        eventDown?.post(tap: .cghidEventTap)
        eventUp?.post(tap: .cghidEventTap)

        Logger.shared.log("Cmd+V sent")
    }
}

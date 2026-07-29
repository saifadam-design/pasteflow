import Foundation
import AppKit

class PasteManager {
    let clipboardManager = ClipboardManager()

    @MainActor
    func paste(text: String) async {
        clipboardManager.saveClipboard()
        clipboardManager.replaceClipboard(with: text)

        // Wait 40ms
        try? await Task.sleep(nanoseconds: 40_000_000)

        self.sendCmdV()

        // Wait 80ms
        try? await Task.sleep(nanoseconds: 80_000_000)

        if SettingsManager.shared.restoreClipboard {
            self.clipboardManager.restoreClipboard()
        }
    }

    private func sendCmdV() {
        let vKeyCode: CGKeyCode = 9 // 'v' key
        let commandFlag = CGEventFlags.maskCommand

        let source = CGEventSource(stateID: .hidSystemState)
        let eventDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true)
        let eventUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)

        eventDown?.flags = commandFlag
        eventUp?.flags = []

        eventDown?.post(tap: .cghidEventTap)
        eventUp?.post(tap: .cghidEventTap)

        Logger.shared.log("Cmd+V sent")
    }
}

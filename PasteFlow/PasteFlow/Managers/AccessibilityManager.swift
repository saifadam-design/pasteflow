import Foundation
import AppKit

class AccessibilityManager: ObservableObject {
    @Published var isTrusted: Bool = false

    init() {
        checkPermission()
    }

    func checkPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        self.isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        Logger.shared.log("Accessibility permission status: \(self.isTrusted)")
    }

    func openSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
        Logger.shared.log("Opened accessibility settings")
    }
}

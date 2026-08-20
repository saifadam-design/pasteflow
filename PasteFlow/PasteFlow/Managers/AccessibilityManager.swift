import Foundation
import AppKit
@preconcurrency import ApplicationServices

@MainActor
final class AccessibilityManager: NSObject, ObservableObject {
    @Published var isTrusted: Bool = false

    override init() {
        super.init()
        refreshPermission()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func applicationDidBecomeActive() {
        refreshPermission()
    }

    /// Rechecks whether the app currently has Accessibility permission.
    func refreshPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        self.isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        Logger.shared.log("Accessibility permission status: \(self.isTrusted)")
    }

    func openSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
        Logger.shared.log("Opened accessibility settings")
    }
}

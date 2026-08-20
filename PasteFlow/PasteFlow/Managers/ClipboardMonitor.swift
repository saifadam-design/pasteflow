import Foundation
import AppKit
import Combine

@MainActor
final class ClipboardMonitor: ObservableObject {
    @Published private(set) var isRunning = false

    weak var sessionManager: SessionManager?

    private var timer: DispatchSourceTimer?
    private var lastChangeCount: Int = NSPasteboard.general.changeCount
    private var lastTextValue: String?
    private var appPasteTransactionCount = 0

    func configure(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    func start() {
        guard timer == nil else { return }

        let pasteboard = NSPasteboard.general
        lastChangeCount = pasteboard.changeCount
        lastTextValue = pasteboard.string(forType: .string)

        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: .milliseconds(250), leeway: .milliseconds(100))
        timer.setEventHandler { [weak self] in
            Task { @MainActor in
                self?.pollClipboard()
            }
        }
        timer.resume()

        self.timer = timer
        isRunning = true
        Logger.shared.log("Clipboard monitor started")
    }

    func stop() {
        timer?.cancel()
        timer = nil
        isRunning = false
        appPasteTransactionCount = 0
        lastTextValue = nil
        lastChangeCount = NSPasteboard.general.changeCount
        Logger.shared.log("Clipboard monitor stopped")
    }

    func updateMonitoring(isEnabled: Bool) {
        if isEnabled {
            start()
        } else {
            stop()
        }
    }

    func beginAppPasteTransaction() {
        appPasteTransactionCount += 1
    }

    func endAppPasteTransaction() {
        guard appPasteTransactionCount > 0 else { return }

        appPasteTransactionCount -= 1
        guard appPasteTransactionCount == 0 else { return }

        let pasteboard = NSPasteboard.general
        lastChangeCount = pasteboard.changeCount
        lastTextValue = pasteboard.string(forType: .string)
    }

    private func pollClipboard() {
        guard timer != nil, appPasteTransactionCount == 0 else { return }

        let pasteboard = NSPasteboard.general
        let changeCount = pasteboard.changeCount
        guard changeCount != lastChangeCount else { return }

        lastChangeCount = changeCount

        guard let copiedText = pasteboard.string(forType: .string) else {
            lastTextValue = nil
            return
        }

        guard copiedText != lastTextValue else { return }

        lastTextValue = copiedText
        sessionManager?.importText(copiedText)
    }
}
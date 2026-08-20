import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

@main
struct PasteFlowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var sessionManager = SessionManager()
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var clipboardMonitor: ClipboardMonitor
    @Environment(\.openWindow) private var openWindow

    init() {
        _clipboardMonitor = StateObject(wrappedValue: ClipboardMonitor())
        Logger.shared.log("PasteFlow launched")
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView(sessionManager: sessionManager)
                .onAppear {
                    clipboardMonitor.configure(sessionManager: sessionManager)
                    sessionManager.clipboardMonitor = clipboardMonitor
                    ShortcutManager.shared.setup(sessionManager: sessionManager)

                    clipboardMonitor.updateMonitoring(isEnabled: settingsManager.autoImportCopiedText)

                    if settingsManager.startInMenuBar {
                        NSApp.windows.first?.close()
                    }
                }
                .onChange(of: settingsManager.autoImportCopiedText) { isEnabled in
                    clipboardMonitor.updateMonitoring(isEnabled: isEnabled)
                }
        }
        .windowResizability(.contentSize)

        Settings {
            PreferencesView(sessionManager: sessionManager)
        }

        MenuBarExtra("PF", systemImage: "doc.on.clipboard") {
            Button("Paste Next") {
                sessionManager.pasteNext()
            }

            Button("Restart") {
                sessionManager.restart()
            }

            Button("Skip") {
                sessionManager.skip()
            }

            Button("Clear") {
                sessionManager.clear()
            }

            Divider()

            Button("Show Main Window") {
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            }

            Button("Preferences...") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                NSApp.activate(ignoringOtherApps: true)
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

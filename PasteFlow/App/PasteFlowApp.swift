import SwiftUI

@main
struct PasteFlowApp: App {
    @StateObject private var sessionManager = SessionManager()
    @Environment(\.openWindow) private var openWindow

    init() {
        Logger.shared.log("PasteFlow launched")
        ShortcutManager.shared.setup(sessionManager: _sessionManager.wrappedValue)
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView(sessionManager: sessionManager)
        }
        .windowResizability(.contentSize)

        Settings {
            PreferencesView()
        }

        MenuBarExtra("PasteFlow", systemImage: "doc.on.clipboard") {
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

            Button("Open Window") {
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

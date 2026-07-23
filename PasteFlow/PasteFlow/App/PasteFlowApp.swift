import SwiftUI

@main
struct PasteFlowApp: App {
    @StateObject private var sessionManager = SessionManager()
    @Environment(\.openWindow) private var openWindow

    init() {
        Logger.shared.log("PasteFlow launched")
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView(sessionManager: sessionManager)
                .onAppear {
                    ShortcutManager.shared.setup(sessionManager: sessionManager)
                }
        }
        .windowResizability(.contentSize)

        Settings {
            PreferencesView()
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

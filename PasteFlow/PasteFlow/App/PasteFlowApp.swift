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
    @Environment(\.openWindow) private var openWindow

    init() {
        Logger.shared.log("PasteFlow launched")
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView(sessionManager: sessionManager)
                .onAppear {
                    ShortcutManager.shared.setup(sessionManager: sessionManager)

                    if settingsManager.startInMenuBar {
                        NSApp.windows.first?.close()
                    }
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

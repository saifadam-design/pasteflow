import SwiftUI
import KeyboardShortcuts

struct PreferencesView: View {
    @ObservedObject private var settingsManager = SettingsManager.shared

    var body: some View {
        Form {
            Section(header: Text("Settings")) {
                Toggle("Launch at Login", isOn: $settingsManager.launchAtLogin)
                Toggle("Restore Clipboard", isOn: $settingsManager.restoreClipboard)
                Toggle("Auto Advance", isOn: $settingsManager.autoAdvance)
                Toggle("Start in Menu Bar", isOn: $settingsManager.startInMenuBar)
            }

            Section(header: Text("Global Shortcuts")) {
                KeyboardShortcuts.Recorder("Paste Next", name: .pasteNext)
                KeyboardShortcuts.Recorder("Restart", name: .restart)
                KeyboardShortcuts.Recorder("Skip", name: .skip)
                KeyboardShortcuts.Recorder("Clear", name: .clear)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}

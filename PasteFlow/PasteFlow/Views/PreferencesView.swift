import SwiftUI
import KeyboardShortcuts

struct PreferencesView: View {
    @ObservedObject var sessionManager: SessionManager
    @ObservedObject private var settingsManager = SettingsManager.shared

    var body: some View {
        Form {
            Section(header: Text("Settings")) {
                Toggle("Automatically import copied text", isOn: $settingsManager.autoImportCopiedText)
                Toggle("Launch at Login", isOn: $settingsManager.launchAtLogin)
                Toggle("Restore Clipboard", isOn: $settingsManager.restoreClipboard)
                Toggle("Auto Advance", isOn: $settingsManager.autoAdvance)
                Toggle("Start in Menu Bar", isOn: $settingsManager.startInMenuBar)
            }

            Section(header: Text("Formatting")) {
                TextField("Prefix", text: $settingsManager.prefixText)
                TextField("Suffix", text: $settingsManager.suffixText)
                Toggle("Enable Prefix", isOn: $settingsManager.enablePrefix)
                Toggle("Enable Suffix", isOn: $settingsManager.enableSuffix)
                Toggle("Prefix Space", isOn: $settingsManager.prefixSpace)
                Toggle("Suffix Space", isOn: $settingsManager.suffixSpace)
            }

            Section(header: Text("Preview")) {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Original")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(sessionManager.formattingPreviewOriginalText)
                            .font(.system(.body, design: .monospaced))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Output")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(sessionManager.formattingPreviewOutputText)
                            .font(.system(.body, design: .monospaced))
                    }
                }
                .padding(.vertical, 4)
            }

            Section(header: Text("Global Shortcuts")) {
                KeyboardShortcuts.Recorder("Paste Next", name: .pasteNext)
                KeyboardShortcuts.Recorder("Restart", name: .restart)
                KeyboardShortcuts.Recorder("Skip", name: .skip)
                KeyboardShortcuts.Recorder("Clear", name: .clear)
            }
        }
        .frame(width: 420, height: 500)
    }
}

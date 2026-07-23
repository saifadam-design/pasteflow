import SwiftUI
import KeyboardShortcuts

struct PreferencesView: View {
    var body: some View {
        Form {
            Section(header: Text("Global Shortcuts")) {
                KeyboardShortcuts.Recorder("Paste Next", name: .pasteNext)
                KeyboardShortcuts.Recorder("Restart", name: .restart)
                KeyboardShortcuts.Recorder("Skip", name: .skip)
                KeyboardShortcuts.Recorder("Clear", name: .clear)
            }
        }
        .padding()
        .frame(width: 400, height: 250)
    }
}

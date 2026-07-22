import SwiftUI
import Carbon

struct PreferencesView: View {
    @StateObject private var shortcutManager = ShortcutManager.shared

    var body: some View {
        Form {
            Section(header: Text("Global Shortcuts")) {
                ForEach(ShortcutType.allCases) { type in
                    HStack {
                        Text(type.rawValue)
                        Spacer()
                        ShortcutRecorderView(type: type, currentInfo: shortcutManager.shortcuts[type])
                    }
                }
            }
        }
        .padding()
        .frame(width: 400, height: 250)
    }
}

// A simple representation of a shortcut recorder
// Since writing a full custom NSViewRepresentable for catching keyboard events is complex,
// we provide a simplified view here where users could ideally record a shortcut.
struct ShortcutRecorderView: View {
    let type: ShortcutType
    let currentInfo: ShortcutInfo?

    @State private var isRecording = false

    var body: some View {
        Button(action: {
            isRecording.toggle()
        }) {
            if isRecording {
                Text("Type Shortcut...")
                    .foregroundColor(.secondary)
            } else if let info = currentInfo {
                Text(shortcutString(for: info))
            } else {
                Text("Not Set")
            }
        }
        .buttonStyle(.bordered)
    }

    // Simplistic formatting for standard defaults
    private func shortcutString(for info: ShortcutInfo) -> String {
        // This is a minimal formatter. A full app would map keyCode back to string.
        let mods = info.modifiers
        var str = ""

        if (mods & UInt32(cmdKey)) != 0 { str += "⌘" }
        if (mods & UInt32(optionKey)) != 0 { str += "⌥" }
        if (mods & UInt32(shiftKey)) != 0 { str += "⇧" }
        if (mods & UInt32(controlKey)) != 0 { str += "⌃" }

        switch info.keyCode {
        case 9: str += "V"
        case 36: str += "↩"
        case 124: str += "→"
        case 51: str += "⌫"
        default: str += "Key \(info.keyCode)"
        }

        return str
    }
}

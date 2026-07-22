import Foundation
import Carbon
import AppKit

class ShortcutManager: ObservableObject {
    static let shared = ShortcutManager()

    @Published var shortcuts: [ShortcutType: ShortcutInfo] = [:]

    var sessionManager: SessionManager?

    private var eventHandler: EventHandlerRef?
    private var registeredHotKeys: [ShortcutType: EventHotKeyRef] = [:]

    private let userDefaultsKey = "CustomShortcuts"

    private init() {
        loadShortcuts()
    }

    func setup(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        registerEventHandler()
        registerAllShortcuts()
    }

    private func loadShortcuts() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([ShortcutType: ShortcutInfo].self, from: data) {
            shortcuts = decoded
        } else {
            // Default shortcuts
            shortcuts = [
                .pasteNext: ShortcutInfo(keyCode: 9, modifiers: UInt32(cmdKey | optionKey)), // ⌥⌘V
                .restart: ShortcutInfo(keyCode: 36, modifiers: UInt32(cmdKey | optionKey)), // ⌥⌘↩
                .skip: ShortcutInfo(keyCode: 124, modifiers: UInt32(cmdKey | optionKey)), // ⌥⌘→
                .clear: ShortcutInfo(keyCode: 51, modifiers: UInt32(cmdKey | optionKey)) // ⌥⌘⌫
            ]
            saveShortcuts()
        }
    }

    private func saveShortcuts() {
        if let encoded = try? JSONEncoder().encode(shortcuts) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    func updateShortcut(for type: ShortcutType, with newShortcut: ShortcutInfo) -> Bool {
        // Detect conflicts
        if shortcuts.contains(where: { $0.key != type && $0.value == newShortcut }) {
            Logger.shared.log("Shortcut conflict detected for \(type.rawValue)")
            return false
        }

        // Unregister old
        if let hotKeyRef = registeredHotKeys[type] {
            UnregisterEventHotKey(hotKeyRef)
            registeredHotKeys.removeValue(forKey: type)
        }

        shortcuts[type] = newShortcut
        saveShortcuts()

        // Register new
        registerHotKey(type: type, info: newShortcut)
        Logger.shared.log("Updated shortcut for \(type.rawValue)")

        return true
    }

    private func registerEventHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let handler: EventHandlerUPP = { (nextHandler, theEvent, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)

            if status == noErr {
                let shortcutManager = Unmanaged<ShortcutManager>.fromOpaque(userData!).takeUnretainedValue()
                shortcutManager.handleHotKey(id: Int(hotKeyID.id))
            }

            return noErr
        }

        let userData = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(GetApplicationEventTarget(), handler, 1, &eventType, userData, &eventHandler)
    }

    private func registerAllShortcuts() {
        for (type, info) in shortcuts {
            registerHotKey(type: type, info: info)
        }
        Logger.shared.log("All shortcuts registered")
    }

    private func registerHotKey(type: ShortcutType, info: ShortcutInfo) {
        var hotKeyRef: EventHotKeyRef?
        let typeId = typeId(for: type)
        let hotKeyID = EventHotKeyID(signature: OSType(32), id: UInt32(typeId))
        let status = RegisterEventHotKey(info.keyCode, info.modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)

        if status == noErr, let ref = hotKeyRef {
            registeredHotKeys[type] = ref
        } else {
            Logger.shared.error("Failed to register shortcut for \(type.rawValue)")
        }
    }

    private func typeId(for type: ShortcutType) -> Int {
        switch type {
        case .pasteNext: return 1
        case .restart: return 2
        case .skip: return 3
        case .clear: return 4
        }
    }

    private func handleHotKey(id: Int) {
        DispatchQueue.main.async {
            guard let sessionManager = self.sessionManager else { return }

            switch id {
            case 1:
                Logger.shared.log("Shortcut detected: Paste Next")
                sessionManager.pasteNext()
            case 2:
                Logger.shared.log("Shortcut detected: Restart")
                sessionManager.restart()
            case 3:
                Logger.shared.log("Shortcut detected: Skip")
                sessionManager.skip()
            case 4:
                Logger.shared.log("Shortcut detected: Clear")
                sessionManager.clear()
            default:
                break
            }
        }
    }
}

import Foundation
import AppKit

class ClipboardManager {
    private var savedItems: [NSPasteboardItem]?

    func saveClipboard() {
        let pasteboard = NSPasteboard.general
        if let items = pasteboard.pasteboardItems {
            savedItems = items.map { item in
                let newItem = NSPasteboardItem()
                for type in item.types {
                    if let data = item.data(forType: type) {
                        newItem.setData(data, forType: type)
                    }
                }
                return newItem
            }
            Logger.shared.log("Clipboard saved")
        }
    }

    func replaceClipboard(with text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        Logger.shared.log("Clipboard replaced with chunk")
    }

    func restoreClipboard() {
        guard let savedItems = savedItems else { return }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        pasteboard.writeObjects(savedItems)

        self.savedItems = nil
        Logger.shared.log("Clipboard restored")
    }
}

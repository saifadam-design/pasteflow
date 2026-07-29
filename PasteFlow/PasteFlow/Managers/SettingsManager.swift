import Foundation
import Combine
import SwiftUI

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
    @AppStorage("restoreClipboard") var restoreClipboard: Bool = true
    @AppStorage("autoAdvance") var autoAdvance: Bool = true
    @AppStorage("startInMenuBar") var startInMenuBar: Bool = false

    private init() {}
}

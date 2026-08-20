import Foundation
import Combine
import SwiftUI

@MainActor
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @AppStorage("autoImportCopiedText") var autoImportCopiedText: Bool = true
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
    @AppStorage("restoreClipboard") var restoreClipboard: Bool = true
    @AppStorage("autoAdvance") var autoAdvance: Bool = true
    @AppStorage("startInMenuBar") var startInMenuBar: Bool = false
    @AppStorage("prefixText") var prefixText: String = ""
    @AppStorage("suffixText") var suffixText: String = ""
    @AppStorage("enablePrefix") var enablePrefix: Bool = false
    @AppStorage("enableSuffix") var enableSuffix: Bool = false
    @AppStorage("prefixSpace") var prefixSpace: Bool = false
    @AppStorage("suffixSpace") var suffixSpace: Bool = false

    private init() {}
}

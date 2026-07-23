import Foundation
import OSLog

final class Logger {
    static let shared = Logger()

    let appLogger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.pasteflow.app", category: "App")

    private init() {}

    func log(_ message: String) {
        appLogger.info("\(message, privacy: .public)")
    }

    func error(_ message: String) {
        appLogger.error("\(message, privacy: .public)")
    }

    func debug(_ message: String) {
        appLogger.debug("\(message, privacy: .public)")
    }
}

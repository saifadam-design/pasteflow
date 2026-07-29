import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var sessionManager: SessionManager
    @StateObject private var accessibilityManager = AccessibilityManager()

    var body: some View {
        VStack(spacing: 20) {
            if !accessibilityManager.isTrusted {
                accessibilityWarningView
            }

            ToolbarView(sessionManager: sessionManager)

            Divider()

            if sessionManager.session.chunks.isEmpty {
                ImportView(sessionManager: sessionManager)
            } else {
                VStack(spacing: 20) {
                    Text("Chunk \(min(sessionManager.session.currentIndex + 1, sessionManager.session.chunks.count)) / \(sessionManager.session.chunks.count)")
                        .font(.headline)

                    Divider()

                    SessionView(sessionManager: sessionManager)

                    ChunkCardView(sessionManager: sessionManager)

                    Divider()

                    ProgressView(value: sessionManager.session.progress)
                        .progressViewStyle(LinearProgressViewStyle())

                    HStack(spacing: 20) {
                        Button("Restart") { sessionManager.restart() }
                        Button("Skip") { sessionManager.skip() }
                        Button("Clear") { sessionManager.clear() }
                        Button("Trigger") { sessionManager.pasteNext() }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }

    private var accessibilityWarningView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
            Text("Accessibility permissions required.")
            Spacer()
            Button("Open Settings") {
                accessibilityManager.openSettings()
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(8)
    }
}

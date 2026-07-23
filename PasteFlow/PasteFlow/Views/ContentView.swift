import SwiftUI

struct ContentView: View {
    @ObservedObject var sessionManager: SessionManager
    @StateObject private var accessibilityManager = AccessibilityManager()

    var body: some View {
        VStack(spacing: 20) {
            if !accessibilityManager.isTrusted {
                accessibilityWarningView
            }

            topBar

            if sessionManager.session.chunks.isEmpty {
                ImportView(sessionManager: sessionManager)
            } else {
                VStack(spacing: 20) {
                    SessionView(sessionManager: sessionManager)
                    Spacer()
                    ProgressViewCustom(sessionManager: sessionManager)
                }
            }
        }
        .padding()
        .frame(width: 800, height: 600)
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

    private var topBar: some View {
        HStack {
            Text("Mode")
                .font(.headline)
            Spacer()
            Picker("Split Mode", selection: $sessionManager.session.mode) {
                ForEach(SplitMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 350)
            .onChange(of: sessionManager.session.mode) { _ in
                // Re-split the imported text if the mode changes
                if !sessionManager.session.chunks.isEmpty {
                    // Extract the raw text from the original chunks to re-import
                    let rawText = sessionManager.session.chunks.map { $0.text }.joined(separator: sessionManager.session.mode == .word ? " " : "")
                    sessionManager.importText(rawText)
                }
            }
        }
    }
}

import SwiftUI

struct ContentView: View {
    @ObservedObject var sessionManager: SessionManager
    @StateObject private var accessibilityManager = AccessibilityManager()
    @State private var inputText: String = ""

    var body: some View {
        VStack(spacing: 20) {
            if !accessibilityManager.isTrusted {
                accessibilityWarningView
            }

            topBar

            if sessionManager.chunks.isEmpty {
                importView
            } else {
                activeSessionView
            }
        }
        .padding()
        .frame(width: 400, height: 300)
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
            Picker("Split Mode", selection: $sessionManager.splitMode) {
                ForEach(SplitMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 250)
            .onChange(of: sessionManager.splitMode) { _ in
                if !inputText.isEmpty {
                    sessionManager.importText(inputText)
                }
            }
        }
    }

    private var importView: some View {
        VStack {
            TextEditor(text: $inputText)
                .font(.body)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))

            Button("Import Text") {
                sessionManager.importText(inputText)
            }
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private var activeSessionView: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("NEXT TO PASTE")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(sessionManager.currentChunk ?? "Finished!")
                    .font(.title2)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }

            Spacer()

            VStack(spacing: 12) {
                ProgressView(value: sessionManager.progress)
                    .progressViewStyle(LinearProgressViewStyle())

                HStack {
                    Text("\(sessionManager.currentIndex) / \(sessionManager.chunks.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }

                HStack(spacing: 20) {
                    Button(action: { sessionManager.restart() }) {
                        VStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Restart")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { sessionManager.skip() }) {
                        VStack {
                            Image(systemName: "forward.end.fill")
                            Text("Skip")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        sessionManager.clear()
                        inputText = ""
                    }) {
                        VStack {
                            Image(systemName: "trash")
                            Text("Clear")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

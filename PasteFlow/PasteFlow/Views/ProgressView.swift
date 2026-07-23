import SwiftUI

struct ProgressViewCustom: View {
    @ObservedObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 12) {
            ProgressView(value: sessionManager.session.progress)
                .progressViewStyle(LinearProgressViewStyle())

            HStack {
                Text("\(sessionManager.session.currentIndex) / \(sessionManager.session.chunks.count)")
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

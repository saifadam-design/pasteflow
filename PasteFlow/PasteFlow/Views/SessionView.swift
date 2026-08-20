import SwiftUI

struct SessionView: View {
    @ObservedObject var sessionManager: SessionManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NEXT TO PASTE")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(sessionManager.currentFormattedChunkText ?? "Finished!")
                .font(.title2)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

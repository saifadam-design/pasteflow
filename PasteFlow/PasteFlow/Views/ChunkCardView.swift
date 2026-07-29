import SwiftUI

struct ChunkCardView: View {
    @ObservedObject var sessionManager: SessionManager

    var body: some View {
        VStack {
            Text(sessionManager.session.currentChunk?.text ?? "Finished!")
                .font(.title2)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

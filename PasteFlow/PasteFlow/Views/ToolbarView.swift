import SwiftUI

struct ToolbarView: View {
    @ObservedObject var sessionManager: SessionManager

    var body: some View {
        HStack {
            Text("Mode: \(sessionManager.session.mode.rawValue)")
                .font(.headline)
            Spacer()

            Picker("Mode", selection: $sessionManager.session.mode) {
                ForEach(SplitMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 250)
            .onChange(of: sessionManager.session.mode) { _ in
                sessionManager.rebuildSession()
            }
        }
    }
}

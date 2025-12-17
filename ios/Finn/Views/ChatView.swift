import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss;
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                Spacer()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                Text("AI Insight")
                    .font(.system(size: 19, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 16)
        }
    }
    
}

import SwiftUI

struct CreateTransactionView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "CFDBF8"),
                    Color(hex: "FFFFFF")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.3)
            .ignoresSafeArea()
            
            ScrollView{
                Text("Create Transaction")
            }
        }
        .navigationTitle("Create Transaction")
    }
}

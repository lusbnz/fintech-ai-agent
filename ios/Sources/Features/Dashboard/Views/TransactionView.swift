import SwiftUI

struct TransactionView: View {
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
            .opacity(0.5)
            .ignoresSafeArea()
            
            ScrollView{
                Text("Transaction")
            }
        }
        .navigationTitle("Transaction")
    }
}

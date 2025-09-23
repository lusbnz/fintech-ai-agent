import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Chào mừng bạn vào HomeView")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Bạn đã đăng nhập thành công!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button(action: {
                    TokenManager.shared.clear()
                }) {
                    Text("Đăng xuất")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Home")
        }
    }
}

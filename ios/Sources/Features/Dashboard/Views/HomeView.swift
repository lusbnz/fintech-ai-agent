import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

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

            ScrollView {
                HStack {
                    Text("Hi, \(authViewModel.userProfile?.display_name ?? "Guest")!")
                       .font(.system(size: 24, weight: .semibold))
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            // action Plan
                        }) {
                            Text("Plan")
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .shadow(radius: 2)
                        }
                        
                        NavigationLink {
                           SettingView(authViewModel: authViewModel)
                       } label: {
                           Image(systemName: "gearshape")
                               .font(.system(size: 16))
                               .foregroundColor(.black)
                               .padding(6)
                               .background(Color.white)
                               .clipShape(Circle())
                               .shadow(radius: 2)
                       }
                    }
                }
                .padding(.horizontal)
            }
        }
        .task {
            await authViewModel.fetchProfile()
        }
        .navigationTitle("Home")
    }
}

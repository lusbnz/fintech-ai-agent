import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel(authService: AppleSignInService())
    @State private var facebookViewModel = LoginViewModel(authService: FacebookSignInService())
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Đăng nhập vào \(Constants.appName)")
                    .font(.title)
                
                if let error = viewModel.errorMessage ?? facebookViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                HStack(spacing: 10) {
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { _ in }
                    )
                    .frame(width: 100, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button(action: {
                        Task {
                            await facebookViewModel.loginWithSocial(provider: "Facebook")
                        }
                    }) {
                        Text("Facebook")
                            .frame(width: 100)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                    Text("Chào mừng!")
                }
                .navigationDestination(isPresented: $facebookViewModel.isLoggedIn) {
                    Text("Chào mừng!")
                }
            }
            .padding()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Đăng nhập vào \(Constants.appName)")
                    .font(.title)
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                SecureField("Mật khẩu", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    Task {
                        await viewModel.login()
                    }
                }) {
                    Text("Đăng nhập")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
                
                // Social Login Buttons
                HStack(spacing: 10) {
                    Button(action: {
                        Task {
                            await viewModel.loginWithSocial(provider: "Apple")
                        }
                    }) {
                        Text("Apple")
                            .frame(width: 100)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.loginWithSocial(provider: "Google")
                        }
                    }) {
                        Text("Google")
                            .frame(width: 100)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.loginWithSocial(provider: "Facebook")
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
                
                
                // Điều hướng khi đăng nhập thành công
                .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                    Text("Chào mừng!") // Thay bằng HomeView sau
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

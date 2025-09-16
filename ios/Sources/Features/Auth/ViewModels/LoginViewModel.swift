import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    
    private let authService: AuthService
    
    init(authService: AuthService = FakeAuthService()) {
        self.authService = authService
    }
    
    func login() async {
        do {
            let user = try await authService.loginWithEmail(email: email, password: password)
            isLoggedIn = true
            errorMessage = nil
        } catch {
            errorMessage = "Đăng nhập thất bại: \(error.localizedDescription)"
        }
    }
    
    func loginWithSocial(provider: String) async {
        do {
            let user = try await authService.loginWithSocial(provider: provider)
            isLoggedIn = true
            errorMessage = nil
        } catch {
            errorMessage = "Đăng nhập \(provider) thất bại: \(error.localizedDescription)"
        }
    }
}

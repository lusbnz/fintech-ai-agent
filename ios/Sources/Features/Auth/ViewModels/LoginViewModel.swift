import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
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

import Foundation
import Combine

protocol AuthService {
    func loginWithEmail(email: String, password: String) async throws -> User
    func loginWithSocial(provider: String) async throws -> User
    func signup(email: String, password: String) async throws -> User
}

class FakeAuthService: AuthService {
    func loginWithEmail(email: String, password: String) async throws -> User {
        // Giả lập đăng nhập
        try await Task.sleep(nanoseconds: 1_000_000_000) // Delay 1s
        return User(id: UUID().uuidString, email: email, name: nil)
    }
    
    func loginWithSocial(provider: String) async throws -> User {
        // Giả lập đăng nhập social
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return User(id: UUID().uuidString, email: "\(provider)@example.com", name: nil)
    }
    
    func signup(email: String, password: String) async throws -> User {
        // Giả lập đăng ký
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return User(id: UUID().uuidString, email: email, name: nil)
    }
}

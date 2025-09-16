import Foundation
import FirebaseAuth

protocol AuthService {
    func loginWithSocial(provider: String) async throws -> User
}

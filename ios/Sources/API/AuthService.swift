import Foundation

final class AuthService {
    static let shared = AuthService()
    private init() {}

    func loginWithFirebaseToken(_ firebaseToken: String) async throws {
        let response: AuthResponse = try await APIClient.shared.request(
            .login(firebaseToken: firebaseToken),
            as: AuthResponse.self
        )
        TokenManager.shared.accessToken = response.data.access_token
        TokenManager.shared.refreshToken = response.data.refresh_token
    }

    func refreshToken() async throws {
        guard let refresh = TokenManager.shared.refreshToken else {
            throw APIError.unauthorized
        }
        let response: AuthResponse = try await APIClient.shared.request(
            .refresh(refreshToken: refresh),
            as: AuthResponse.self
        )
        TokenManager.shared.accessToken = response.data.access_token
        TokenManager.shared.refreshToken = response.data.refresh_token
    }

    func getProfile() async throws -> User {
        let response: UserResponse = try await APIClient.shared.request(.profile, as: UserResponse.self)
        return response.data
    }
    
    func updateProfile(body: [String: Any]) async throws -> User {
        let response: UserResponse = try await APIClient.shared.request(
            .updateProfile(body: body),
            as: UserResponse.self
        )
        return response.data
    }
}

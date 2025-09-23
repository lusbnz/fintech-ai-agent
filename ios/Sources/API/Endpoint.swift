import Foundation

enum Endpoint {
    static let baseURL = "https://qlct.vercel.app/api/v1"

    case login(firebaseToken: String)
    case refresh(refreshToken: String)
    case profile

    var url: URL {
        switch self {
        case .login:
            return URL(string: Endpoint.baseURL + "/auth/login")!
        case .refresh:
            return URL(string: Endpoint.baseURL + "/auth/refresh-token")!
        case .profile:
            return URL(string: Endpoint.baseURL + "/users/profile")!
        }
    }

    var method: String {
        switch self {
        case .login, .refresh:
            return "POST"
        case .profile:
            return "GET"
        }
    }

    func makeRequest() throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        switch self {
        case .login(let firebaseToken):
            request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")

        case .refresh(let refreshToken):
            request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
            let body = ["refresh_token": refreshToken]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

        case .profile:
            if let token = TokenManager.shared.accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        return request
    }
}

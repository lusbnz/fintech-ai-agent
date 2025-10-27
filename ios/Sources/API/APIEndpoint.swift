import Foundation

enum Endpoint {
    static let baseURL = "https://qlct.vercel.app/api/v1"

    case login(firebaseToken: String)
    case refresh(refreshToken: String)
    case profile
    case updateProfile(body: [String: Any])
    case budgetList(page: Int)
    case budgetCreate
    case budgetUpdate(id: String)
    case budgetDelete(id: String)

    var url: URL {
        switch self {
        case .login:
            return URL(string: Endpoint.baseURL + "/auth/login")!
        case .refresh:
            return URL(string: Endpoint.baseURL + "/auth/refresh-token")!
        case .profile:
            return URL(string: Endpoint.baseURL + "/users/profile")!
        case .updateProfile:
            return URL(string: Endpoint.baseURL + "/users/profile")!
        case .budgetList:
            return URL(string: Endpoint.baseURL + "/budgets/list")!
        case .budgetCreate:
            return URL(string: Endpoint.baseURL + "/budgets/create")!
        case .budgetUpdate(let id):
            return URL(string: Endpoint.baseURL + "/budgets/\(id)")!
        case .budgetDelete(let id):
            return URL(string: Endpoint.baseURL + "/budgets/\(id)")!
        }
    }

    var method: String {
        switch self {
        case .login, .refresh:
            return "POST"
        case .profile:
            return "GET"
        case .updateProfile:
            return "POST"
        case .budgetList: 
            return "GET"
        case .budgetCreate: 
            return "POST"
        case .budgetUpdate: 
            return "PUT"
        case .budgetDelete: 
            return "DELETE"
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
                
            case .updateProfile(let body):
                if let token = TokenManager.shared.accessToken {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            case .budgetList:
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")

            case .budgetCreate:
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")

            case .budgetUpdate(let id):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")

            case .budgetDelete(let id):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        }

        return request
    }

}

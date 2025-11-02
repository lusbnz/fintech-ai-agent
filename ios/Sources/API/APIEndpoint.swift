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
    case transactionList(page: Int, filter: TransactionFilter?)
    case transactionCreate(body: [String: Any])
    case transactionUpdate(id: String, body: [String: Any])
    case transactionDelete(id: String)
    case uploadImage
    case getPrices(version: String)

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
        case .transactionList:
            return URL(string: Endpoint.baseURL + "/transactions/list")!
        case .transactionCreate:
            return URL(string: Endpoint.baseURL + "/transactions/create")!
        case .transactionUpdate(let id):
            return URL(string: Endpoint.baseURL + "/transactions/\(id)")!
        case .transactionDelete(let id):
            return URL(string: Endpoint.baseURL + "/transactions/\(id)")!
        case .uploadImage:
            return URL(string: Endpoint.baseURL + "/upload/image")!
        case .getPrices:
            return URL(string: Endpoint.baseURL + "/prices")!
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
        case .transactionList, .transactionCreate:
            return "POST"
        case .transactionUpdate:
            return "PUT"
        case .transactionDelete:
            return "DELETE"
        case .uploadImage:
            return "POST"
        case .getPrices:
            return "GET"
        }
    }

    func makeRequest(imageData: Data? = nil) throws -> URLRequest {
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
            
            case .transactionList(let page, let filter):
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                var json: [String: Any] = ["page": page]
                if let filter = filter, !filter.toJSON().isEmpty {
                    json["filter"] = filter.toJSON()
                }
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                request.httpBody = try JSONSerialization.data(withJSONObject: json)
                
            case .transactionCreate(let body):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            case .transactionUpdate(_, let body):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                request.httpBody = try JSONSerialization.data(withJSONObject: body)

            case .transactionDelete(let id):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
            
            case .uploadImage:
                let boundary = "Boundary-\(UUID().uuidString)"
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                if let token = TokenManager.shared.accessToken {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }

                guard let imageData = imageData else {
                    throw NSError(domain: "UploadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image data is required"])
                }

                var body = Data()

                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
                body.append("--\(boundary)--\r\n".data(using: .utf8)!)

                request.httpBody = body
            case .getPrices:
                if let token = TokenManager.shared.accessToken {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
        }

        return request
    }

}

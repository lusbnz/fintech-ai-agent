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
    case transactionReccurringList(page: Int, filter: TransactionFilter?)
    case transactionReccurringUpdate(id: String, body: [String: Any])
    case notiList(page: Int)
    case notiUpdate(id: String, body: [String: Any])
    case chatList(page: Int)
    case createChat(body: [String: Any])
    case createChatResponse(id: String, body: [String: Any])
    case categoryList(page: Int)
    case categoryCreate(body: [String: Any])
    case categoryUpdate(id: String, body: [String: Any])
    case categoryDelete(id: String)
    case uploadImage
    case getPrices(version: String)
    case feedbackCreate(body: [String: Any])
    case getDashboard(body: [String: Any])

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
        case .transactionUpdate(let id, _):
            return URL(string: Endpoint.baseURL + "/transactions/\(id)")!
        case .transactionDelete(let id):
            return URL(string: Endpoint.baseURL + "/transactions/\(id)")!
        case .transactionReccurringList:
            return URL(string: Endpoint.baseURL + "/recurring-transactions")!
        case .transactionReccurringUpdate(let id, _):
            return URL(string: Endpoint.baseURL + "/recurring-transactions/\(id)")!
        case .notiList:
            return URL(string: Endpoint.baseURL + "/notifications/list")!
        case .notiUpdate(let id, _):
            return URL(string: Endpoint.baseURL + "/notifications/\(id)")!
        case .chatList:
            return URL(string: Endpoint.baseURL + "/chats")!
        case .createChat:
            return URL(string: Endpoint.baseURL + "/chats")!
        case .createChatResponse(let id, _):
            return URL(string: Endpoint.baseURL + "/chats/\(id)/reverse")!
        case .categoryList:
            return URL(string: Endpoint.baseURL + "/categories/list")!
        case .categoryCreate:
            return URL(string: Endpoint.baseURL + "/categories/create")!
        case .categoryUpdate(let id, _):
            return URL(string: Endpoint.baseURL + "/categories/\(id)")!
        case .categoryDelete(let id):
            return URL(string: Endpoint.baseURL + "/categories/\(id)")!
        case .uploadImage:
            return URL(string: Endpoint.baseURL + "/upload/image")!
        case .getPrices:
            return URL(string: Endpoint.baseURL + "/prices")!
        case .feedbackCreate:
            return URL(string: Endpoint.baseURL + "/feedbacks/create")!
        case .getDashboard:
            return URL(string: Endpoint.baseURL + "/dashboards/overview")!
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
        case .transactionReccurringList:
            return "GET"
        case .transactionReccurringUpdate:
            return "PUT"
        case .notiList:
            return "GET"
        case .notiUpdate:
            return "PUT"
        case .chatList:
            return "GET"
        case .createChat:
            return "POST"
        case .createChatResponse:
            return "POST"
        case .categoryList:
            return "GET"
        case .categoryCreate:
            return "POST"
        case .categoryUpdate:
            return "PUT"
        case .categoryDelete:
            return "DELETE"
        case .uploadImage:
            return "POST"
        case .getPrices:
            return "GET"
        case .feedbackCreate:
            return "POST"
        case .getDashboard:
            return "POST"
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

            case .budgetUpdate(_):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")

            case .budgetDelete(_):
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

            case .transactionDelete(_):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                
            case .transactionReccurringList(let page, let filter):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
            
            case .transactionReccurringUpdate(_, let body):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                
            case .notiList(let page):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
            
            case .notiUpdate(_, let body):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                
            case .chatList(let page):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                
            case .categoryList(let page):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
               
            case .createChat(let body):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            case .createChatResponse(_, let body):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                
            case .categoryCreate(let body):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            case .categoryUpdate(_, let body):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                request.httpBody = try JSONSerialization.data(withJSONObject: body)

            case .categoryDelete(_):
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
            
            case .feedbackCreate(let body):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            case .getDashboard(let body):
                request.setValue("Bearer \(TokenManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        return request
    }

}

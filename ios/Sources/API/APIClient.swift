import Foundation

enum APIError: Error {
    case invalidResponse
    case decodingError
    case unauthorized
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        var request = try endpoint.makeRequest()
        
        print("[API] Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        if let body = request.httpBody {
            print("Body: \(String(data: body, encoding: .utf8) ?? "nil")")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code:", httpResponse.statusCode)
        }
        print("Raw Response:", String(data: data, encoding: .utf8) ?? "nil")

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 403 {
            print("403 Unauthorized → thử refresh token")
            try await AuthService.shared.refreshToken()
            request = try endpoint.makeRequest()

            print("Retry Request:", request.url?.absoluteString ?? "")

            let (retryData, retryResponse) = try await URLSession.shared.data(for: request)

            if let retryHttp = retryResponse as? HTTPURLResponse {
                print("Retry Status Code:", retryHttp.statusCode)
            }
            print("Retry Raw Response:", String(data: retryData, encoding: .utf8) ?? "nil")

            guard let retryHttp = retryResponse as? HTTPURLResponse,
                  200..<300 ~= retryHttp.statusCode else {
                throw APIError.unauthorized
            }
            return try JSONDecoder().decode(T.self, from: retryData)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.invalidResponse
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}


import Foundation

enum APIError: Error {
    case invalidResponse
    case decodingError
    case unauthorized
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    func request<T: Decodable>(
        _ endpoint: Endpoint,
        body: [String: Any]? = nil,
        as type: T.Type
    ) async throws -> T {
        var request = try endpoint.makeRequest()
        
        if let body = body, request.httpMethod != "GET" {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            print("[API] Body: \(body)")
        }

        print("[API] Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        if let bodyData = request.httpBody,
           let bodyString = String(data: bodyData, encoding: .utf8) {
            print("Body: \(bodyString)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
        }
        print("Raw Response: \(String(data: data, encoding: .utf8) ?? "nil")")

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 403 {
            print("403 Unauthorized")
            try await AuthService.shared.refreshToken()

            var retryRequest = try endpoint.makeRequest()
            if let body = body {
                retryRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
            }

            print("Retry Request: \(retryRequest.url?.absoluteString ?? "")")

            let (retryData, retryResponse) = try await URLSession.shared.data(for: retryRequest)

            if let retryHttp = retryResponse as? HTTPURLResponse {
                print("Retry Status Code: \(retryHttp.statusCode)")
            }
            print("Retry Raw Response: \(String(data: retryData, encoding: .utf8) ?? "nil")")

            guard let retryHttp = retryResponse as? HTTPURLResponse,
                  200..<300 ~= retryHttp.statusCode else {
                throw APIError.unauthorized
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            return try decoder.decode(T.self, from: retryData)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding Error: \(error)")
            throw APIError.decodingError
        }
    }
}

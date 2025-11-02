import Foundation

actor PriceService {
    static let shared = PriceService()
    
    func getPrices(version: String = "vi", token: String) async throws -> PriceResponse {
        let request = try Endpoint.getPrices(version: version).makeRequest(token: token)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(PriceResponse.self, from: data)
        return decoded
    }
}

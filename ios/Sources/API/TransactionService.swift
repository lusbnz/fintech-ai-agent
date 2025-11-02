import Foundation
import UIKit

final class TransactionService {
    static let shared = TransactionService()
    private init() {}
    
    func getTransactions(page: Int = 1, filter: TransactionFilter? = nil) async throws -> TransactionListResponse {
        let endpoint = Endpoint.transactionList(page: page, filter: filter)
        
        let response: APIResponse<TransactionListResponse> = try await APIClient.shared.request(
            endpoint,
            as: APIResponse<TransactionListResponse>.self
        )
        
        return response.data
    }
    
    func createTransaction(
        name: String,
        amount: Double,
        category: String,
        note: String? = nil,
        date: String,
        type: String, // "income" | "outcome"
        budget_id: String? = nil,
        image: String? = nil
    ) async throws -> Transaction {
        let body: [String: Any] = [
            "name": name,
            "amount": amount,
            "category": category,
            "description": note ?? NSNull(),
            "date_time": date,
            "type": type,
            "budget_id": budget_id ?? NSNull(),
            "image": image ?? NSNull()
        ].compactMapValues { $0 is NSNull ? nil : $0 }
        
        let response: APIResponse<Transaction> = try await APIClient.shared.request(
            .transactionCreate(body: body),
            body: body,
            as: APIResponse<Transaction>.self
        )
        return response.data
    }
    
    func updateTransaction(
        id: String,
        name: String,
        amount: Double? = nil,
        category: String? = nil,
        note: String? = nil,
        date: String? = nil,
        type: String? = nil,
        budget_id: String? = nil,
        image: String? = nil
    ) async throws -> Transaction {
        var body: [String: Any] = [:]
        body["name"] = name
        if let amount = amount { body["amount"] = amount }
        if let category = category { body["category"] = category }
        if let note = note { body["description"] = note }
        if let date = date { body["date_time"] = date }
        if let type = type { body["type"] = type }
        if let budget_id = budget_id { body["budget_id"] = budget_id }
        if let image = image { body["image"] = image }

        let cleanBody = body.compactMapValues { $0 is NSNull ? nil : $0 }

        let response: APIResponse<Transaction> = try await APIClient.shared.request(
            .transactionUpdate(id: id, body: cleanBody),
            body: cleanBody,
            as: APIResponse<Transaction>.self
        )
        return response.data
    }

    
    func deleteTransaction(id: String) async throws {
        _ = try await APIClient.shared.request(
            .transactionDelete(id: id),
            as: APIResponse<EmptyResponse>.self
        )
    }
    
    func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "UploadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }
        
        let request = try Endpoint.uploadImage.makeRequest(imageData: imageData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "UploadError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image"])
        }
        
        struct UploadResponse: Codable {
            let status: Int
            let data: UploadData
        }
        
        struct UploadData: Codable {
            let url: String
        }
        
        let decoded = try JSONDecoder().decode(UploadResponse.self, from: data)
        return decoded.data.url
    }
}

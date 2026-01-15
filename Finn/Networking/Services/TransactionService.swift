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
    
    func getReccurringTransactions(page: Int = 1, filter: TransactionFilter? = nil) async throws -> TransactionReccurringListResponse {
        let endpoint = Endpoint.transactionReccurringList(page: page, filter: filter)
        
        let response: APIResponse<TransactionReccurringListResponse> = try await APIClient.shared.request(
            endpoint,
            as: APIResponse<TransactionReccurringListResponse>.self
        )
        
        return response.data
    }
    
    func createTransaction(
        name: String,
        amount: Double,
        category_id: String? = nil,
        note: String? = nil,
        date: String,
        type: String,
        budget_id: String? = nil,
        image: String? = nil,
        is_recurring: Bool? = nil,
        recurring_start_date: String? = nil,
        recurring_interval_unit: String? = nil,
        recurring_interval_value: Int? = nil,
    ) async throws -> Transaction {
        var body: [String: Any] = [
            "name": name,
            "amount": amount,
            "date_time": date,
            "type": type
        ]

        if let note = note {
            body["description"] = note
        }
        if let budget_id = budget_id {
            body["budget_id"] = budget_id
        }
        if let category_id = category_id {
            body["category_id"] = category_id
        }
        if let image = image {
            body["image"] = image
        }
        if let is_recurring = is_recurring {
            body["is_recurring"] = is_recurring
        }
        if let recurring_start_date = recurring_start_date {
            body["recurring_start_date"] = recurring_start_date
        }
        if let recurring_interval_unit = recurring_interval_unit {
            body["recurring_interval_unit"] = recurring_interval_unit
        }
        if let recurring_interval_value = recurring_interval_value {
            body["recurring_interval_value"] = recurring_interval_value
        }
        
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
        category_id: String? = nil,
        note: String? = nil,
        date: String? = nil,
        type: String? = nil,
        budget_id: String? = nil,
        image: String? = nil,
        is_recurring: Bool? = nil,
        recurring_start_date: String? = nil,
        recurring_interval_unit: String? = nil,
        recurring_interval_value: Int? = nil,
    ) async throws -> Transaction {
        var body: [String: Any] = [:]
        body["name"] = name
        if let amount = amount { body["amount"] = amount }
        if let category_id = category_id { body["category_id"] = category_id }
        if let note = note { body["description"] = note }
        if let date = date { body["date_time"] = date }
        if let type = type { body["type"] = type }
        if let budget_id = budget_id { body["budget_id"] = budget_id }
        if let image = image { body["image"] = image }
        if let is_recurring = is_recurring { body["is_recurring"] = is_recurring }
        if let recurring_start_date = recurring_start_date { body["recurring_start_date"] = recurring_start_date }
        if let recurring_interval_unit = recurring_interval_unit { body["recurring_interval_unit"] = recurring_interval_unit }
        if let recurring_interval_value = recurring_interval_value { body["recurring_interval_value"] = recurring_interval_value }

        let cleanBody = body.compactMapValues { $0 is NSNull ? nil : $0 }

        let response: APIResponse<Transaction> = try await APIClient.shared.request(
            .transactionUpdate(id: id, body: cleanBody),
            body: cleanBody,
            as: APIResponse<Transaction>.self
        )
        return response.data
    }

    func updateReccurringTransaction(
        id: String,
        name: String,
        amount: Double? = nil,
        category_id: String? = nil,
        note: String? = nil,
        date: String? = nil,
        type: String? = nil,
        budget_id: String? = nil,
        image: String? = nil,
        active: Bool? = nil,
        interval_unit: String? = nil,
        interval_value: Int? = nil,
        next_run_at: String? = nil,
        last_run_at: String? = nil,
    ) async throws -> TransactionReccurring {
        var body: [String: Any] = [:]
        body["name"] = name
        if let amount = amount { body["amount"] = amount }
        if let category_id = category_id { body["category_id"] = category_id }
        if let note = note { body["description"] = note }
        if let date = date { body["date_time"] = date }
        if let type = type { body["type"] = type }
        if let budget_id = budget_id { body["budget_id"] = budget_id }
        if let image = image { body["image"] = image }
        if let interval_unit = interval_unit { body["interval_unit"] = interval_unit }
        if let interval_value = interval_value { body["interval_value"] = interval_value }
        if let last_run_at = last_run_at { body["last_run_at"] = last_run_at }
        if let active = active { body["active"] = active }

        let cleanBody = body.compactMapValues { $0 is NSNull ? nil : $0 }

        let response: APIResponse<TransactionReccurring> = try await APIClient.shared.request(
            .transactionReccurringUpdate(id: id, body: cleanBody),
            body: cleanBody,
            as: APIResponse<TransactionReccurring>.self
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

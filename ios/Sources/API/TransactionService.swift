import Foundation

final class TransactionService {
    static let shared = TransactionService()
    private init() {}
    
    // MARK: - Get Transactions (with pagination + filter)
    func getTransactions(page: Int = 1, filter: TransactionFilter? = nil) async throws -> TransactionListResponse {
        let endpoint = Endpoint.transactionList(page: page, filter: filter)
        let response: TransactionListResponse = try await APIClient.shared.request(
            endpoint,
            as: TransactionListResponse.self
        )
        return response
    }
    
    // MARK: - Create Transaction
    func createTransaction(
        amount: Double,
        category: String,
        note: String? = nil,
        date: String, // ISO: "2025-04-05"
        type: String, // "income" | "expense"
        budget_id: String? = nil,
        image_url: String? = nil
    ) async throws -> Transaction {
        let body: [String: Any] = [
            "amount": amount,
            "category": category,
            "note": note ?? NSNull(),
            "date": date,
            "type": type,
            "budget_id": budget_id ?? NSNull(),
            "image_url": image_url ?? NSNull()
        ].compactMapValues { $0 is NSNull ? nil : $0 }
        
        let response: APIResponse<Transaction> = try await APIClient.shared.request(
            .transactionCreate(body: body),
            body: body,
            as: APIResponse<Transaction>.self
        )
        return response.data
    }
    
    // MARK: - Update Transaction
    func updateTransaction(
        id: String,
        amount: Double? = nil,
        category: String? = nil,
        note: String? = nil,
        date: String? = nil,
        type: String? = nil,
        budget_id: String? = nil,
        image_url: String? = nil
    ) async throws -> Transaction {
        var body: [String: Any] = [:]
        if let amount = amount { body["amount"] = amount }
        if let category = category { body["category"] = category }
        if let note = note { body["note"] = note }
        if let date = date { body["date"] = date }
        if let type = type { body["type"] = type }
        if let budget_id = budget_id { body["budget_id"] = budget_id }
        if let image_url = image_url { body["image_url"] = image_url }
        
        // Only send non-null optional fields
        let cleanBody = body.compactMapValues { $0 is NSNull ? nil : $0 }
        
        let response: APIResponse<Transaction> = try await APIClient.shared.request(
            .transactionUpdate(id: id, body: cleanBody),
            body: cleanBody,
            as: APIResponse<Transaction>.self
        )
        return response.data
    }
    
    // MARK: - Delete Transaction
    func deleteTransaction(id: String) async throws {
        _ = try await APIClient.shared.request(
            .transactionDelete(id: id),
            as: APIResponse<EmptyResponse>.self
        )
    }
}
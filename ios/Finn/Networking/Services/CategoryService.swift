import Foundation
import UIKit

final class CategoryService {
    static let shared = CategoryService()
    private init() {}
    
    func getCategories(page: Int = 1) async throws -> CategoryListResponse {
        let endpoint = Endpoint.categoryList(page: page)
        
        let response: APIResponse<CategoryListResponse> = try await APIClient.shared.request(
            endpoint,
            as: APIResponse<CategoryListResponse>.self
        )
        
        return response.data
    }
    
    func createCategory(
        name: String,
    ) async throws -> Category {
        let body: [String: Any] = [
            "name": name,
        ]
        
        let response: APIResponse<Category> = try await APIClient.shared.request(
            .categoryCreate(body: body),
            body: body,
            as: APIResponse<Category>.self
        )
        return response.data
    }
    
    func updateCategory(
        id: String,
        name: String,
    ) async throws -> Category {
        var body: [String: Any] = [:]
        body["name"] = name

        let cleanBody = body.compactMapValues { $0 is NSNull ? nil : $0 }

        let response: APIResponse<Category> = try await APIClient.shared.request(
            .categoryUpdate(id: id, body: cleanBody),
            body: cleanBody,
            as: APIResponse<Category>.self
        )
        return response.data
    }

    
    func deleteCategory(id: String) async throws {
        _ = try await APIClient.shared.request(
            .categoryDelete(id: id),
            as: APIResponse<EmptyResponse>.self
        )
    }
}

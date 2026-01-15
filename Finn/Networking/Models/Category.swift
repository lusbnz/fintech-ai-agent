import Foundation

struct CategoryListResponse: Codable {
    let data: [Category]
    let pagination: Pagination
}

struct Category: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let color: String
    let is_default: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description, color, is_default
    }
}

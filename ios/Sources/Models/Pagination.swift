import Foundation

struct Pagination: Codable {
    let total: Int
    let page: Int
    let limit: Int
    let total_page: Int

    enum CodingKeys: String, CodingKey {
        case total, page, limit
        case total_page = "total_page"
    }
}

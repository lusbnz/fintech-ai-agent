import Foundation

struct NotiResponse: Codable {
    let data: [Noti]
    let pagination: Pagination
}

struct Noti: Codable, Identifiable {
    let id: String
    let user_id: String
    let type: String
    let description: String
    let meta: [String: AnyCodable]
    let is_read: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user_id, type, description, meta, is_read
    }
}

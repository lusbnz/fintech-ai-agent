import Foundation

struct ChatListResponse: Codable {
    let data: [Chat]
    let pagination: Pagination
}

struct Chat: Codable, Identifiable {
    let id: String
    let user_id: String
    let is_me: Bool
    let message: MessageItem
    let created_at: String
    let updated_at: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user_id, is_me, message, created_at, updated_at
    }
}

struct MessageItem: Codable {
    let id: String?
    let text: String
    let image: String?
    let card: [MessageCard]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case text, card, image
    }
}

struct MessageCard: Codable {
    let type: String
    let amount: Double
    let description: String
}

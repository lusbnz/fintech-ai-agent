import Foundation

struct APIResponse<T: Codable>: Codable {
    let status: Int
    let data: T
    let message: String
}

struct EmptyResponse: Codable {}

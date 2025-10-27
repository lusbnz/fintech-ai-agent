// File: APIResponse.swift
import Foundation

/// Dùng chung cho mọi API trả về format:
// {
//   "status": 200,
//   "data": { ... },
//   "message": "Success"
// }
struct APIResponse<T: Codable>: Codable {
    let status: Int
    let data: T
    let message: String
}

// Dùng cho API không trả data (như delete)
struct EmptyResponse: Codable {}
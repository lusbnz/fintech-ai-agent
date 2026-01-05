import Foundation

struct NotiListData: Codable {
    let data: [Noti]
    let pagination: Pagination
}

struct Noti: Codable, Identifiable {
    let id: String
    let user_id: String
    let type: String
    let title: String?
    let description: String?
    let meta: [String: JSONValue]?
    let is_read: Bool?
    let created_at: String?
    let updated_at: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user_id
        case type
        case title
        case description
        case meta
        case is_read
        case created_at
        case updated_at
    }
    
    func metaString(_ key: String) -> String? {
        meta?[key]?.stringValue
    }
    
    func metaInt(_ key: String) -> Int? {
        meta?[key]?.intValue
    }
    
    func metaDouble(_ key: String) -> Double? {
        meta?[key]?.doubleValue
    }
    
    func metaBool(_ key: String) -> Bool? {
        meta?[key]?.boolValue
    }
}

enum JSONValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
            return
        }
        
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
            return
        }
        
        if let value = try? container.decode(Int.self) {
            self = .int(value)
            return
        }
        
        if let value = try? container.decode(Double.self) {
            self = .double(value)
            return
        }
        
        if let value = try? container.decode(String.self) {
            self = .string(value)
            return
        }
        
        if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
            return
        }
        
        if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
            return
        }
        
        throw DecodingError.typeMismatch(JSONValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode JSONValue"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }
    
    var stringValue: String? {
        if case .string(let value) = self { return value }
        return nil
    }
    
    var intValue: Int? {
        switch self {
        case .int(let value): return value
        case .double(let value): return Int(value)
        default: return nil
        }
    }
    
    var doubleValue: Double? {
        switch self {
        case .double(let value): return value
        case .int(let value): return Double(value)
        default: return nil
        }
    }
    
    var boolValue: Bool? {
        if case .bool(let value) = self { return value }
        return nil
    }
}

import Foundation

struct PlanOption: Codable, Identifiable {
    var id: String { code }
    let code: String
    let display: String
    let duration: Int
    let unit: String
    let price: Double
}

struct FeatureItem: Codable, Identifiable {
    var id: String { code }
    let code: String
    let type: String
    let value: CodableValue
}

enum CodableValue: Codable {
    case string(String)
    case number(Double)
    case bool(Bool)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let b = try? container.decode(Bool.self) {
            self = .bool(b)
        } else if let d = try? container.decode(Double.self) {
            self = .number(d)
        } else if let s = try? container.decode(String.self) {
            self = .string(s)
        } else {
            throw DecodingError.typeMismatch(
                CodableValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown type")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let s): try container.encode(s)
        case .number(let d): try container.encode(d)
        case .bool(let b): try container.encode(b)
        }
    }
}

struct PriceResponse: Codable {
    let data: PriceData
    let version: String
    let message: String
}

struct PriceData: Codable {
    let plan: [String: [PlanOption]]
    let Feature: [String: [FeatureItem]]
}

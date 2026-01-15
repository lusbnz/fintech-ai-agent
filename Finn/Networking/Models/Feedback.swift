import Foundation
import SwiftUI

struct Feedback: Codable, Identifiable {
    let id: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case description
    }
}

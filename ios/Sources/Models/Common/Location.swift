import Foundation

struct Location: Codable {
    let name: String
    let lat: Double?
    let lng: Double?
    
    init(name: String, lat: Double? = nil, lng: Double? = nil) {
        self.name = name
        self.lat = lat
        self.lng = lng
    }
}

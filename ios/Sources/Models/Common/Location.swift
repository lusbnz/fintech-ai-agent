import Foundation
import MapKit
import CoreLocation

struct Location: Codable {
    let name: String
    let lat: Double?
    let lng: Double?
    
    init(name: String, lat: Double? = nil, lng: Double? = nil) {
        self.name = name
        self.lat = lat
        self.lng = lng
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = lat, let lng = lng else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

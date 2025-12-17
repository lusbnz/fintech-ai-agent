import Foundation
import FirebaseAuth

struct UserFirebase: Identifiable, Codable {
    let id: String
    let email: String?
    let displayName: String?
    let photoURL: String?
    let phoneNumber: String?
    let isEmailVerified: Bool
    let providerID: String?

    init(from user: FirebaseAuth.User) {
        self.id = user.uid
        self.email = user.email
        self.displayName = user.displayName
        self.photoURL = user.photoURL?.absoluteString
        self.phoneNumber = user.phoneNumber
        self.isEmailVerified = user.isEmailVerified
        self.providerID = user.providerData.first?.providerID
    }
}

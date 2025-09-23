struct UserProfile: Decodable {
    let _id: String
    let display_name: String
    let email: String
    let avatar: String?
    let plan: String
    let is_active: Bool
}


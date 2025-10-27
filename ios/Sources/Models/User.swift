struct ProfileResponse: Decodable {
    let status: Int
    let data: UserProfile
    let message: String
}

struct UserProfile: Codable {
    let _id: String
    let display_name: String
    let email: String
    let avatar: String
    let plan: String
    let currency: String? // "usd", "vnd"
    let last_login: String?
    let tags: [String]?
    let is_admin: Bool?
    let is_active: Bool?
    let created_at: String?
    let updated_at: String?
    let lang: String?  // "en", "vi"
    let providers: [Provider]?
}

struct Provider: Codable {
    let provider: String
    let provider_id: String
}

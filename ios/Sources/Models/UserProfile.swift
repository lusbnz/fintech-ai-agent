struct ProfileResponse: Decodable {
    let status: Int
    let data: UserProfile
    let message: String
}

struct UserProfile: Decodable {
    let _id: String
    let display_name: String
    let email: String
    let avatar: String?
    let plan: String
    let is_active: Bool
    let providers: [[String: String]]?
    let currency: String?
    let last_login: String?
    let tags: [String]?
    let is_admin: Bool?
    let created_at: String?
    let updated_at: String?
    let lang: String?
}

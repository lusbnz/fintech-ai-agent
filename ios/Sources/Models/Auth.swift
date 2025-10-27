struct AuthResponse: Decodable {
    let data: AuthData
}

struct AuthData: Decodable {
    let user: User
    let access_token: String
    let refresh_token: String
}

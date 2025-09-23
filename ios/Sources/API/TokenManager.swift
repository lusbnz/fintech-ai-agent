import Foundation

final class TokenManager {
    static let shared = TokenManager()
    private init() {}

    private let accessKey = "access_token"
    private let refreshKey = "refresh_token"

    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: accessKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: accessKey) }
    }

    var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: refreshKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: refreshKey) }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: accessKey)
        UserDefaults.standard.removeObject(forKey: refreshKey)
    }
}

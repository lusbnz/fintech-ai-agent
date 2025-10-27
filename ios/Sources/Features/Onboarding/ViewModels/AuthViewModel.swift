import Combine
import SwiftUI
import GoogleSignIn
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: UserFirebase? = nil
    @Published var userProfile: User? = nil
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false

    init() {
        if TokenManager.shared.accessToken != nil {
            self.isLoggedIn = true
            Task {
                await fetchProfile()
            }
        }
    }

    func signinGoogle() async {
        guard let rootVC = Utilities.shared.topViewController() else {
            print("Không tìm thấy root view controller")
            return
        }

        do {
            isLoading = true
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            guard let googleIdToken = gidSignInResult.user.idToken?.tokenString else {
                throw URLError(.badServerResponse)
            }
            let accessToken = gidSignInResult.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: googleIdToken, accessToken: accessToken)
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseIdToken = try await result.user.getIDToken()
            self.user = UserFirebase(from: result.user)
            try await AuthService.shared.loginWithFirebaseToken(firebaseIdToken)
            await fetchProfile()
            self.isLoggedIn = true
        } catch {
            print("Google Sign-In hoặc Firebase Auth lỗi: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func fetchProfile() async {
        do {
            isLoading = true
            let profile = try await AuthService.shared.getProfile()
            self.userProfile = profile
        } catch {
            print("Lỗi khi lấy profile: \(error.localizedDescription)")
            self.isLoggedIn = false
            TokenManager.shared.clear()
        }
        isLoading = false
    }
    
    func updateProfile(displayName: String? = nil, currency: String? = nil, lang: String? = nil) async throws {
        var body: [String: Any] = [:]
        if let displayName = displayName { body["display_name"] = displayName }
        if let currency = currency { body["currency"] = currency }
        if let lang = lang { body["lang"] = lang }

        let updated = try await AuthService.shared.updateProfile(body: body)
        self.userProfile = updated
    }

    func logout() {
        TokenManager.shared.clear()
        self.user = nil
        self.userProfile = nil
        self.isLoggedIn = false
    }
}

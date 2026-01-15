import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    let app: AppState

    @Published var user: UserFirebase?
    @Published var isLoggedIn = false
    @Published var isLoading = false

    init(app: AppState) {
        self.app = app

        if let token = TokenManager.shared.accessToken, !token.isEmpty {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }

    func signinGoogle() async {
        guard let rootVC = Utilities.shared.topViewController() else {
            print("Error: Cannot find root view controller")
            return
        }

        do {
            isLoading = true

            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            guard let googleIdToken = gidSignInResult.user.idToken?.tokenString else {
                throw URLError(.badServerResponse)
            }

            let accessToken = gidSignInResult.user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(
                withIDToken: googleIdToken,
                accessToken: accessToken
            )

            let result = try await Auth.auth().signIn(with: credential)
            self.user = UserFirebase(from: result.user)

            let firebaseToken = try await result.user.getIDToken()
            try await AuthService.shared.login(firebaseToken)

            app.isAppReady = false
            isLoggedIn = true

            print("Login Success: \(user?.email ?? "-")")
        } catch {
            print("Google Sign-In Error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func updateProfile(
        displayName: String? = nil,
        currency: String? = nil,
        lang: String? = nil,
        avatar: String? = nil
    ) async throws {

        var body: [String: Any] = [:]
        if let displayName = displayName { body["display_name"] = displayName }
        if let currency = currency { body["currency"] = currency }
        if let lang = lang { body["lang"] = lang }
        if let avatar = avatar { body["avatar"] = avatar }

        let updated = try await AuthService.shared.updateProfile(body: body)

        await MainActor.run {
            self.app.profile = updated
        }
    }

    func logout() {
        TokenManager.shared.clear()

        user = nil
        isLoggedIn = false

        app.profile = nil
        app.budgets = []
    }
}

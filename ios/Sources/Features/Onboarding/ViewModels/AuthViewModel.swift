import Combine
import SwiftUI
import GoogleSignIn
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isLoggedIn: Bool = false
    
    func signinGoogle() async {
        guard let rootVC = Utilities.shared.topViewController() else {
            print("Không tìm thấy root view controller")
            return
        }

        do {
            print("Bắt đầu Google Sign-In")
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            print("Google Sign-In thành công, user: \(gidSignInResult.user.profile?.email ?? "unknown")")

            guard let idToken = gidSignInResult.user.idToken?.tokenString else {
                print("Không lấy được idToken từ Google")
                throw URLError(.badServerResponse)
            }
            let accessToken = gidSignInResult.user.accessToken.tokenString
            print("Nhận idToken (Google): \(idToken.prefix(20))...")
            print("Nhận accessToken (Google): \(accessToken.prefix(20))...")

            print("Đăng nhập Firebase bằng Google credential")
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            let result = try await Auth.auth().signIn(with: credential)
            print("Firebase Auth thành công, uid: \(result.user.uid)")

            self.user = result.user

            print("Gọi API login backend với Firebase token")
            try await AuthService.shared.loginWithFirebaseToken(idToken)
            print("API login backend thành công")

            self.isLoggedIn = true
            print("Login flow hoàn tất, email:", result.user.email ?? "")
        } catch {
            print("Google Sign-in error:", error.localizedDescription)
        }
    }
}

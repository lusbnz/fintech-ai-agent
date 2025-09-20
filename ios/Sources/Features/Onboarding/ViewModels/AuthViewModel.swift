import Combine
import SwiftUI
import GoogleSignIn
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    
    func signinGoogle() async throws {
        guard let rootVC = Utilities.shared.topViewController() else {
            print("Không tìm thấy root view controller")
            return
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        let result = try await Auth.auth().signIn(with: credential)
        self.user = result.user
        
        print("Google Sign-in success:", result.user.email ?? "")
    }
}

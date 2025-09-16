import Foundation
import FirebaseAuth
import FBSDKLoginKit

class FacebookSignInService: NSObject, AuthService {
    private var completion: ((Result<User, Error>) -> Void)?
    
    func loginWithSocial(provider: String) async throws -> User {
        try await withCheckedThrowingContinuation { continuation in
            self.completion = { result in
                switch result {
                case .success(let user):
                    continuation.resume(returning: user)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            let loginManager = LoginManager()
            loginManager.logIn(permissions: ["public_profile", "email"], from: nil) { result, error in
                if let error = error {
                    self.completion?(.failure(error))
                    return
                }
                
                guard let accessToken = AccessToken.current?.tokenString else {
                    self.completion?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No Facebook token"])))
                    return
                }
                
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        self.completion?(.failure(error))
                        return
                    }
                    
                    guard let user = authResult?.user else {
                        self.completion?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found"])))
                        return
                    }
                    
                    let email = user.email ?? "unknown@facebook.com"
                    let name = user.displayName
                    self.completion?(.success(User(id: user.uid, email: email, name: name)))
                }
            }
        }
    }
}

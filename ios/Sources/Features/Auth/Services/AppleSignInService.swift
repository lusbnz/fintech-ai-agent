import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class AppleSignInService: NSObject, AuthService {
    private var currentNonce: String?
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
            
            let nonce = randomNonceString()
            self.currentNonce = nonce
            
            let appleIDRequest = ASAuthorizationAppleIDProvider().createRequest()
            appleIDRequest.requestedScopes = [.email, .fullName]
            appleIDRequest.nonce = sha256(nonce)
            
            let controller = ASAuthorizationController(authorizationRequests: [appleIDRequest])
            controller.delegate = self
            controller.performRequests()
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with error code \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce.prefix(length))
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.map { String(format: "%02x", $0) }.joined()
        return hashString
    }
}

extension AppleSignInService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple credential"])))
            return
        }
        
        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                self.completion?(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                self.completion?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found"])))
                return
            }
            
            let email = user.email ?? "unknown@apple.com"
            let name = appleIDCredential.fullName?.givenName
            self.completion?(.success(User(id: user.uid, email: email, name: name)))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(.failure(error))
    }
}

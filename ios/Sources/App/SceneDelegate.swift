import UIKit
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        if GIDSignIn.sharedInstance.handle(url) {
            print("Google Sign-In handled")
        } else {
            print("URL not handled: \(url)")
        }
    }
}

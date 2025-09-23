import UIKit
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@main
struct FinyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var Delegate
  
    var body: some Scene {
        WindowGroup {
          NavigationView {
            ContentView()
          }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
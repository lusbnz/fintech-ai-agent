import UIKit
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@main
struct FinyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var Delegate
    @StateObject private var authViewModel = AuthViewModel()
  
    var body: some Scene {
        WindowGroup {
          NavigationView {
            ContentView()
                  .environmentObject(authViewModel)
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

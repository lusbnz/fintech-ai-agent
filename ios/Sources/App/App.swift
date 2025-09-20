import SwiftUI
import Firebase

@main
struct YourApp: App {
    init() {
        FirebaseApp.configure()
        print("Firebase configured!")
    }
  
    var body: some Scene {
        WindowGroup {
          NavigationView {
            ContentView()
          }
        }
    }
}

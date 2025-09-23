import SwiftUI

struct ContentView: View {
    @StateObject private var authVM = AuthViewModel()
    
    var body: some View {
        Group {
            if authVM.isLoggedIn {
                HomeView()
            } else {
                IntroView()
                    .environmentObject(authVM)
            }
        }
    }
}

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isLoggedIn, authViewModel.userProfile != nil {
            WrapperView()
                .environmentObject(authViewModel)
        } else if !authViewModel.isLoading {
            IntroView()
                .environmentObject(authViewModel)
        }
    }
}

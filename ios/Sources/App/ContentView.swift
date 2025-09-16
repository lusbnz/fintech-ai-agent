import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenIntro") private var hasSeenIntro: Bool = false
    
    var body: some View {
        Group {
            if hasSeenIntro {
                LoginView()
            } else {
                IntroView()
                    .onAppear {
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

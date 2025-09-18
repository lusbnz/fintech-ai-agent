import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenIntro") private var hasSeenIntro: Bool = false
    
    var body: some View {
        Group {
            IntroView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class IntroViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    
    // Sample data for onboarding screens
    let screens: [(title: String, description: String)] = [
        ("Welcome to the App", "Discover amazing features and start your journey with us!"),
        ("Get Started", "Swipe to explore and dive into the experience!")
    ]
}

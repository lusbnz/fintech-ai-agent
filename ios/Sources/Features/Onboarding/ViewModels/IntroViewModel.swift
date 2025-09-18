import Combine

class IntroViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    
    let screens: [(title: String, description: String)] = [
        ("Effortless, Real-Time Chats", "With lightning-speed response times, it processes queries in real-time, offering clear and concise answers without delays."),
        ("AI Assistant", "Your personal AI assistant, here to simplify your life. Whether you need help managing budget, AI is ready to assist you anytime, anywhere."),
        ("Login the Finny!", "Login to your account to see your progress and routes.")
    ]
}

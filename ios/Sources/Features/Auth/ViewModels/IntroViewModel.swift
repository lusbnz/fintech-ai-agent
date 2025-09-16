import SwiftUI
import Foundation
import Combine

@MainActor
class IntroViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var showLogin: Bool = false
    
    let pages = [
        Intro(
            title: "Effortless, Real-Time Chats",
            description: "Experience lightning-speed responses with clear and concise answers, designed to enhance your productivity instantly.",
            imageName: "chat_icon",
            stat: "2 seconds",
            statDescription: "to get an answer"
        )
    ]
    
    var totalPages: Int { pages.count }
    
    func nextPage() {
        if currentPage < totalPages - 1 {
            currentPage += 1
        } else {
            showLogin = true
        }
    }
    
    func goToLogin() {
        showLogin = true
    }
}

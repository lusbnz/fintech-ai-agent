import SwiftUI
import Combine

@MainActor
class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var isFirstDownloader: Bool {
        didSet {
            saveSettings()
        }
    }
    
    @Published var isSettedFirstBudeget: Bool {
        didSet {
            saveFirstUser()
        }
    }

    private init() {
        self.isFirstDownloader = UserDefaults.standard.bool(forKey: "isFirstDownloader")
        self.isSettedFirstBudeget = UserDefaults.standard.bool(forKey: "isSettedFirstBudeget")
    }

    private func saveSettings() {
        UserDefaults.standard.set(isFirstDownloader, forKey: "isFirstDownloader")
    }
    
    private func saveFirstUser() {
        UserDefaults.standard.set(isSettedFirstBudeget, forKey: "isSettedFirstBudeget")
    }
    
    func markRegularUser() {
        isFirstDownloader = true
    }
    
    func markSettedFirstBudeget() {
        isSettedFirstBudeget = true
    }
}


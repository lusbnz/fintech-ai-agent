import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isSending: Bool = false
    @Published var pagination: Pagination?
    @Published var errorMessage: String?

    let app: AppState
    private let service = ChatService.shared

    init(app: AppState) {
        self.app = app
    }

    func loadChats(page: Int = 1) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let result = try await service.getChats(page: page)

            if page == 1 {
                app.chats = result.data
            } else {
                app.chats.append(contentsOf: result.data)
            }

            self.pagination = result.pagination
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func sendMessage(_ text: String, image: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !isSending else { return }

        isSending = true
        errorMessage = nil

        do {
            let (userChat, botChat) = try await service.sendMessage(text, image: image)
            app.chats.insert(userChat, at: 0)
            app.chats.insert(botChat, at: 0)
        } catch {
            self.errorMessage = "Không thể gửi tin nhắn: \(error.localizedDescription)"
            print("Send message error:", error)
        }

        isSending = false
    }
}

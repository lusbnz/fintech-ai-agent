import Foundation
import UIKit

final class ChatService {
    static let shared = ChatService()
    
    private init() {}
    
    
    func getChats(page: Int = 1) async throws -> ChatListResponse {
        let endpoint = Endpoint.chatList(page: page)
        
        let response: APIResponse<ChatListResponse> = try await APIClient.shared.request(
            endpoint,
            as: APIResponse<ChatListResponse>.self
        )
        
        return response.data
    }
    
    func sendMessage(_ message: String, image: String) async throws -> (userChat: Chat, botChat: Chat) {
            let body: [String: Any] = [
                "message": [
                    "text": message,
                    "image": image,
                    "card": [] as [Any]
                ]
            ]
            
            let createEndpoint = Endpoint.createChat(body: body)
            
            let createResponse: APIResponse<Chat> = try await APIClient.shared.request(
                createEndpoint,
                as: APIResponse<Chat>.self
            )
            
            let userChat = createResponse.data
            
            let responseEndpoint = Endpoint.createChatResponse(id: userChat.id, body: [:])
            
            let botResponse: APIResponse<Chat> = try await APIClient.shared.request(
                responseEndpoint,
                as: APIResponse<Chat>.self
            )
            
            let botChat = botResponse.data
            
            return (userChat: userChat, botChat: botChat)
        }
}

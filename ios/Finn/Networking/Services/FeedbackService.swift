import Foundation

final class FeedbackService {
    static let shared = FeedbackService()
    
    private init() {}

    func createFeedback(
        description: String,
    ) async throws -> Feedback {
        let body: [String: Any] = [
            "description": description,
        ]
        
        let response: APIResponse<Feedback> = try await APIClient.shared.request(
            .feedbackCreate(body: body),
            body: body,
            as: APIResponse<Feedback>.self
        )
        return response.data
    }
}

import Foundation
import UIKit

final class NotiService {
    static let shared = NotiService()
    private init() {}
    
    func getNoti(page: Int = 1) async throws -> NotiResponse {
        let endpoint = Endpoint.notiList(page: page)
        
        let response: APIResponse<NotiResponse> = try await APIClient.shared.request(
            endpoint,
            as: APIResponse<NotiResponse>.self
        )
        
        return response.data
    }

    func updateNoti(
        id: String,
        is_read: Bool,
    ) async throws -> Noti {
        var body: [String: Any] = [:]
        body["is_read"] = is_read

        let cleanBody = body.compactMapValues { $0 is NSNull ? nil : $0 }

        let response: APIResponse<Noti> = try await APIClient.shared.request(
            .notiUpdate(id: id, body: cleanBody),
            body: cleanBody,
            as: APIResponse<Noti>.self
        )
        return response.data
    }
}

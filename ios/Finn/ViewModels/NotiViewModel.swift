import Foundation
import Combine

@MainActor
final class NotiViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var noti: [Noti] = []
    @Published var hasMorePages = true
    @Published var currentPage = 1
    
    @Published var showEdit = false
    @Published var showDeleteConfirm = false
    
    private var cancellables = Set<AnyCancellable>()
    private let pageSize = 20
    
    func loadNoti(page: Int = 1, append: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await NotiService.shared.getNoti(page: page)
            
            if Task.isCancelled { return }
            
            if append {
                noti.append(contentsOf: response.data)
            } else {
                noti = response.data
            }
            
            hasMorePages = response.pagination.page < response.pagination.total_page
            currentPage = response.pagination.page

        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("Request was cancelled — ignore safely")
                return
            }

            if error is CancellationError {
                print("Task cancelled — ignore safely")
                return
            }

            self.error = "Failed to load: \(error.localizedDescription)"
        }
    }
    
    func updateNoti(
        id: String,
        is_read: Bool
    ) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            let updatedNoti = try await NotiService.shared.updateNoti(
                id: id,
                is_read: is_read,
            )
            
            if let index = noti.firstIndex(where: { $0.id == id }) {
                noti[index] = updatedNoti
            }
            
            return true
        } catch {
            self.error = "Cập nhật thất bại: \(error.localizedDescription)"
            return false
        }
    }
}

import Foundation
import Combine

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var pagination: Pagination?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let app: AppState
    private let service = CategoryService.shared

    init(app: AppState) {
        self.app = app
    }

    func loadCategories(page: Int = 1) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await service.getCategories(page: page)
            self.categories = result.data
            self.pagination = result.pagination
            app.categories = result.data
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func createCategory(name: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await service.createCategory(name: name)
            await loadCategories()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func updateCategory(id: String, name: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await service.updateCategory(id: id, name: name)
            await loadCategories()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteCategory(id: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await service.deleteCategory(id: id)
            await loadCategories()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

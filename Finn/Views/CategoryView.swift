import SwiftUI

struct CategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var app: AppState
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    
    private struct SheetItem: Identifiable {
        let id = UUID()
    }
    
    @State private var sheetItem: SheetItem? = nil
    
    private let maxCategories = 10
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    ForEach(app.categories) { cat in
                        HStack(spacing: 12) {
                            Text(cat.name)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    .onDelete { indexSet in
                        if app.categories.count - indexSet.count >= 1 {
                            Task {
                                for index in indexSet {
                                    let cat = app.categories[index]
                                    await categoryViewModel.deleteCategory(id: cat.id)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Danh mục của bạn")
                }
                
                Section {
                    Button {
                        if app.categories.count < maxCategories {
                            sheetItem = SheetItem()
                        }
                    } label: {
                        Label("Thêm danh mục", systemImage: "plus.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .disabled(app.categories.count >= maxCategories)
                    .opacity(app.categories.count >= maxCategories ? 0.4 : 1)
                }
            }
        }
        .sheet(item: $sheetItem) { _ in
            AddCategoryContentView()
                .presentationDetents([.height(260)])
                .presentationCornerRadius(24)
        }
        .navigationTitle("Danh mục")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
            }
        }
        .task {
            await categoryViewModel.loadCategories()
        }
    }
}

private struct AddCategoryContentView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newCategory: String = ""
    
    private let maxCategories = 10
    
    private var isLimitReached: Bool {
        categoryViewModel.categories.count >= maxCategories
    }
    
    private var trimmedCategory: String {
        newCategory.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isInputValid: Bool {
        !trimmedCategory.isEmpty && !isLimitReached
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.gray.opacity(0.25))
                .frame(width: 42, height: 5)
                .padding(.top, 10)
            
            Text("Thêm Danh Mục")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "4A4A4A"))
            
            if isLimitReached {
                Text("Bạn đã đạt tối đa \(maxCategories) danh mục")
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
            
            HStack(spacing: 10) {
                Image(systemName: "tag")
                    .foregroundColor(.gray)
                
                TextField("Nhập tên danh mục", text: $newCategory)
                    .autocorrectionDisabled()
                    .foregroundColor(Color(hex: "4A4A4A"))
                    .disabled(isLimitReached)
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
            
            Button {
                Task {
                    print("Tạo danh mục mới: '\(trimmedCategory)'")
                    await categoryViewModel.createCategory(name: trimmedCategory)
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text("Thêm")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                }
                .padding()
                .background(isInputValid ? Color.black.opacity(0.8) : Color.gray.opacity(0.25))
                .foregroundColor(.white)
                .cornerRadius(16)
                .padding(.horizontal)
                .shadow(color: .black.opacity(isInputValid ? 0.15 : 0), radius: 6, x: 0, y: 3)
            }
            .disabled(!isInputValid)
            
            Spacer()
        }
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.95),
                    Color.white.opacity(0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

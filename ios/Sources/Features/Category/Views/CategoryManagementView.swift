import SwiftUI

struct CategoryManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var categories: [String] = [
        "Ăn uống", "Di chuyển", "Mua sắm", "Giải trí", "Hóa đơn", "Khác"
    ]
    
    @State private var newCategory: String = ""
    @State private var isAdding = false
    
    var body: some View {
        VStack {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                Text("Categories")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                
                EditButton()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            List {
                Section {
                    ForEach(categories, id: \.self) { cat in
                        HStack {
                            Image(systemName: iconForCategory(cat))
                                .foregroundColor(.blue)
                            Text(cat)
                        }
                    }
                    .onDelete { indexSet in
                        categories.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        categories.move(fromOffsets: indices, toOffset: newOffset)
                    }
                } header: {
                    Text("Your Categories")
                }
                
                Section {
                    Button {
                        isAdding = true
                    } label: {
                        Label("Add Category", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $isAdding) {
            addCategorySheet
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var addCategorySheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("New Category")
                    .font(.headline)
                
                TextField("Category name", text: $newCategory)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button("Add") {
                    if !newCategory.isEmpty {
                        categories.append(newCategory)
                    }
                    newCategory = ""
                    isAdding = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(newCategory.isEmpty)
                
                Spacer()
            }
            .padding(.top, 40)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isAdding = false }
                }
            }
        }
    }
    
    func iconForCategory(_ category: String) -> String {
        switch category {
        case "Ăn uống": return "fork.knife"
        case "Di chuyển": return "car.fill"
        case "Mua sắm": return "bag.fill"
        case "Hóa đơn": return "creditcard"
        case "Giải trí": return "gamecontroller"
        default: return "square.grid.2x2"
        }
    }
}

import SwiftUI

struct CreateTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
//    @StateObject private var vm = TransactionViewModel()
    @StateObject private var budgetVM = BudgetViewModel()
    
    // MARK: - Edit Mode
    let transactionToEdit: Transaction?
    let onSuccess: (() -> Void)?
    
    init(transaction: Transaction? = nil, onSuccess: (() -> Void)? = nil) {
        self.transactionToEdit = transaction
        self.onSuccess = onSuccess
    }
    
    // MARK: - States
    @State private var amount: String = ""
    @State private var dateTime: Date = Date()
    @State private var transactionName: String = ""
    @State private var selectedBudgetId: String?
    @State private var selectedTypeDisplay: String = "Outcome"
    @State private var description: String = ""
    @State private var selectedCategory: String = "Food"
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showDescriptionInput = false
    
    let categories = ["Food", "Transport", "Shopping", "Entertainment", "Health", "Other"]
    let typeOptions = [("Income", "income"), ("Outcome", "outcome")]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "CFDBF8"), .white]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Spacer()
                    
                    Text(transactionToEdit != nil ? "Edit Transaction" : "Create Transaction")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "636363"))
                    
                    TextField("Transaction Name", text: $transactionName)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: "636363"))
                        .padding(.vertical, 6)
                        .overlay(Rectangle().frame(height: 1).foregroundColor(Color(hex: "E0E0E0")).padding(.top, 40))
                        .padding(.horizontal)
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .padding()
                        .font(.system(size: 28, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(24)
                    
                    Group {
                        infoRow(icon: "dollarsign.circle", title: "Budget") {
                            if budgetVM.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else if budgetVM.budgets.isEmpty {
                                Text("No budgets")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            } else {
                                Picker("", selection: $selectedBudgetId) {
                                    Text("Select Budget").tag(String?.none)
                                    ForEach(budgetVM.budgets) { budget in
                                        Text(budget.name).tag(Optional(budget.id))
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.vertical, 2)
                            }
                        }
                        
                        infoRow(icon: "arrow.left.arrow.right", title: "Type") {
                            Picker("", selection: $selectedTypeDisplay) {
                                ForEach(typeOptions, id: \.0) { display, _ in
                                    Text(display).tag(display)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.vertical, 2)
                        }
                        
                        infoRow(icon: "calendar", title: "Datetime") {
                            DatePicker("", selection: $dateTime, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .padding(.vertical)
                        }
                        
                        infoRow(icon: "mappin.and.ellipse", title: "Location") {
                            CustomButton(title: "Open Map") {
                                // TODO: Open map
                            }
                            .padding(.vertical)
                        }
                        
                        infoRow(icon: "tag", title: "Category") {
                            Picker("", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(.menu)
                            .padding(.vertical, 2)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "text.alignleft")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "636363"))
                            Text("Description")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "636363"))
                            Spacer()
                            CustomButton(title: !showDescriptionInput ? "Add Description" : "Delete") {
                                withAnimation(.easeInOut) {
                                    showDescriptionInput.toggle()
                                }
                            }
                        }
                        
                        if showDescriptionInput {
                            TextEditor(text: $description)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "636363"))
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "E0E0E0"), lineWidth: 1)
                                )
                                .transition(.opacity)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "photo")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "636363"))
                            Text("Image")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "636363"))
                            Spacer()
                            CustomButton(title: "Select Image") { showImagePicker.toggle() }
                        }
                        
                        Text("Choose and upload pictures of the bill or related info.")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "636363"))
                        
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .clipped()
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(16)
                    
                    Spacer(minLength: 160)
                }
                .padding(.horizontal)
            }
            
            // Gradient overlay
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.7),
                        Color.white.opacity(0.8),
                        Color.white.opacity(0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
                .blur(radius: 12)
            }
            .ignoresSafeArea(edges: .bottom)
            
            // Save Button
            VStack {
                Button(action: {
//                    action: saveTransaction
                    print("Save")
                }) {
                    ZStack(alignment: .leading) {
                        Text(
//                            vm.isLoading ? "Saving..." : (transactionToEdit != nil ? "Update" : "Create")
                            "Create"
                        )
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(Color.black.opacity(0.75))
//                                    .fill(vm.isLoading ? Color.gray : Color.black.opacity(0.75))
                            )
                            .opacity(1.0)
//                            .opacity(vm.isLoading ? 0.7 : 1.0)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background(Circle().fill(Color.black))
//                            .background(Circle().fill(vm.isLoading ? Color.gray : Color.black))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
//                .disabled(vm.isLoading || !isValid)
                .padding(.horizontal)
                .padding(.bottom, 40)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
//        .alert("Error", isPresented: .constant(vm.error != nil)) {
//            Button("OK") { vm.error = nil }
//        } message: {
//            Text(vm.error ?? "")
//        }
        .task {
            await budgetVM.loadBudgets()
        }
//        .onAppear {
//            if let transaction = transactionToEdit {
//                fillData(from: transaction)
//            }
//        }
    }
    
    private var isValid: Bool {
        !transactionName.isEmpty &&
        !amount.isEmpty &&
        Double(amount) != nil &&
        selectedBudgetId != nil
    }
    
//    private func fillData(from transaction: Transaction) {
//        transactionName = transaction.name
//        amount = "\(Int(transaction.amount))"
//        dateTime = transaction.startDate
//        selectedCategory = transaction.category
//        description = transaction.description ?? ""
//        selectedBudgetId = transaction.budget_id
//        selectedTypeDisplay = transaction.type == "income" ? "Income" : "Outcome"
//        
//        if !transaction.image.isEmpty, let url = URL(string: transaction.image) {
//            Task {
//                if let (data, _) = try? await URLSession.shared.data(from: url),
//                   let uiImage = UIImage(data: data) {
//                    selectedImage = uiImage
//                }
//            }
//        }
//    }
    
//    private func saveTransaction() {
//        guard let amountDouble = Double(amount),
//              let budgetId = selectedBudgetId else { return }
//        
//        let typeValue = typeOptions.first { $0.0 == selectedTypeDisplay }?.1 ?? "outcome"
//        let location = Location(name: "Unknown")
//        let imageBase64 = selectedImage?.jpegData(compressionQuality: 0.8)?.base64EncodedString() ?? ""
//        
//        Task {
//            let success: Bool
//            
//            if let transaction = transactionToEdit {
//                // UPDATE
//                success = await vm.updateTransaction(
//                    id: transaction.id,
//                    name: transactionName,
//                    budget_id: budgetId,
//                    category: selectedCategory,
//                    amount: amountDouble,
//                    dateTime: dateTime,
//                    location: location,
//                    image: imageBase64,
//                    type: typeValue,
//                )
//            } else {
//                // CREATE
//                success = await vm.createTransaction(
//                    name: transactionName,
//                    budget_id: budgetId,
//                    category: selectedCategory,
//                    amount: amountDouble,
//                    dateTime: dateTime,
//                    location: location,
//                    image: imageBase64,
//                    type: typeValue
//                )
//            }
//            
//            if success {
//                onSuccess?()
//                dismiss()
//            }
//        }
//    }
    
    private func infoRow<Content: View>(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "636363"))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "636363"))
                Spacer()
                content()
            }
        }
        .padding(.horizontal)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
}

// MARK: - Custom Button
struct CustomButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "636363"))
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "D9D9D9"))
                )
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }
    }
}

import SwiftUI

struct CreateTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var app: AppState
    @EnvironmentObject var budgetViewModel: BudgetViewModel
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    
    let transactionToEdit: Transaction?
    let onSuccess: (() -> Void)?
    let defaultBudgetId: String?
    let defaultCategoryId: String?
    
    init(transaction: Transaction? = nil, defaultBudgetId: String? = nil, defaultCategoryId: String? = nil, onSuccess: (() -> Void)? = nil) {
        self.transactionToEdit = transaction
        self.onSuccess = onSuccess
        self.defaultBudgetId = defaultBudgetId
        self.defaultCategoryId = defaultCategoryId
    }
    
    @State private var transactionName: String = ""
    @State private var amount: String = ""
    @State private var dateTime: Date = Date()
    @State private var selectedBudgetId: String?
    @State private var selectedTypeDisplay: String = "Chi ra"
    @State private var description: String = ""
    @State private var selectedCategoryId: String?
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showDescriptionInput = false
    
    @State private var showDeleteConfirm = false
    
    @State private var isScheduledTransfer: Bool = false
    @State private var scheduleStartDate: Date = Date()
    @State private var schedulePeriod: String = "1 Tháng"
    
    @State private var isRecurring: Bool = false
    @State private var recurringStartDate: Date = Date()
    @State private var recurringIntervalUnit: String = "month"

    let recurringUnits = ["1 Tuần", "1 Tháng", "1 Năm"]

    let schedulePeriods = ["1 Tuần", "1 Tháng", "1 Năm"]
    
    let typeOptions = [("Nạp vào", "income"), ("Chi ra", "outcome")]
    
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
                    
                    Text(transactionToEdit != nil ? "Chi tiết giao dịch" : "Tạo giao dịch")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "636363"))
                    
                    TextField("Tên giao dịch", text: $transactionName)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: "636363"))
                        .padding(.vertical, 6)
                        .overlay(Rectangle().frame(height: 1).foregroundColor(Color(hex: "E0E0E0")).padding(.top, 40))
                        .padding(.horizontal)
                    
                    TextField("Số tiền", text: $amount)
                        .keyboardType(.decimalPad)
                        .padding()
                        .font(.system(size: 28, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(24)
                    
                    Group {
                        if transactionToEdit == nil {
                            infoRow(icon: "dollarsign.circle", title: "Budget") {
                                if budgetViewModel.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .padding(.vertical)
                                } else if app.budgets.isEmpty {
                                    Text("Không có ngân sách")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                } else {
                                    Picker("", selection: $selectedBudgetId) {
                                        Text("Chọn ngân sách").tag(String?.none)
                                        ForEach(app.budgets) { budget in
                                            Text(budget.name).tag(Optional(budget.id))
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        
                        infoRow(icon: "arrow.left.arrow.right", title: "Loại") {
                            Picker("", selection: $selectedTypeDisplay) {
                                ForEach(typeOptions, id: \.0) {
                                    display, _ in Text(display).tag(display)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.vertical, 2)
                        }
                        
                        infoRow(icon: "calendar", title: "Thời gian") {
                            DatePicker("", selection: $dateTime, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .padding(.vertical)
                        }
                        
                        infoRow(icon: "tag", title: "Danh mục") {
                            if app.categories.isEmpty {
                                Text("Không có danh mục")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            } else {
                                Picker("", selection: $selectedCategoryId) {
                                    Text("Chọn danh mục").tag(String?.none)
                                    ForEach(app.categories) { category in
                                        Text(category.name).tag(Optional(category.id))
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.vertical, 2)
                            }
                        }
                        
                        if  transactionToEdit == nil {
                            Toggle(isOn: $isRecurring) {
                                HStack {
                                    Image(systemName: "repeat")
                                        .foregroundColor(Color(hex: "636363"))
                                    Text("Giao dịch định kỳ")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(hex: "636363"))
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .black))
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(16)
                            .animation(.easeInOut, value: isRecurring)
                        }

                        if isRecurring && transactionToEdit == nil {
                            infoRow(icon: "calendar", title: "Ngày bắt đầu định kỳ") {
                                DatePicker("", selection: $recurringStartDate, displayedComponents: [.date])
                                    .labelsHidden()
                                    .padding(.vertical)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))

                            infoRow(icon: "clock.arrow.circlepath", title: "Chu kỳ lặp lại") {
                                Picker("", selection: $recurringIntervalUnit) {
                                    Text("1 tuần").tag("week")
                                    Text("1 tháng").tag("month")
                                    Text("1 năm").tag("year")
                                }
                                .pickerStyle(.menu)
                                .padding(.vertical, 2)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "text.alignleft")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "636363"))
                            Text("Mô tả")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "636363"))
                            Spacer()
                            CustomButton(title: !showDescriptionInput ? "Thêm mô tả" : "Xoá") {
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
                            Text("Ảnh")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "636363"))
                            Spacer()
                            CustomButton(title: "Chọn ảnh") { showImagePicker.toggle() }
                        }
                        
                        Text("Chọn và tải ảnh thông tin hoá đơn của bạn.")
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
            
            VStack {
                Button(action: {
                    saveTransaction()
                }) {
                    ZStack(alignment: .leading) {
                        Text(
                            transactionViewModel.isLoading ? "Đang lưu..." : (transactionToEdit != nil ? "Cập nhật" : "Tạo mới")
                        )
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(isFormValid ? Color.black.opacity(0.75) : Color.gray.opacity(0.5))
                            )
                            .opacity(1.0)
                            .opacity(transactionViewModel.isLoading ? 0.7 : 1.0)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background(
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(isFormValid ? Color.black : Color.gray.opacity(0.5))
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .disabled(transactionViewModel.isLoading || !isFormValid)
                .padding(.horizontal)
                .padding(.bottom, 40)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .navigationBarBackButtonHidden(true)
        .hideKeyboardOnTap()
        .toolbar {
            leadingToolbar
            trailingToolbar
        }
        .alert("Error", isPresented: .constant(transactionViewModel.error != nil)) {
            Button("OK") { transactionViewModel.error = nil }
        } message: {
            Text(transactionViewModel.error ?? "")
        }
        .task {
            if let prefill = defaultBudgetId {
                selectedBudgetId = prefill
            } else if let firstBudget = app.budgets.first {
                selectedBudgetId = firstBudget.id
            }
            if let prefill = defaultCategoryId {
                selectedCategoryId = prefill
            } else if let firstCategory = app.categories.first {
                selectedCategoryId = firstCategory.id
            }
        }
        .alert("Xoá giao dịch", isPresented: $showDeleteConfirm) {
            Button("Huỷ", role: .cancel) {}

            Button("Xoá", role: .destructive) {
                if let transaction = transactionToEdit {
                    Task {
                        let success = await transactionViewModel.deleteTransaction(transaction)
                        if success { dismiss() }
                    }
                }
            }
        } message: {
            Text("Bạn có chắc là muốn xoá giao dịch “\(transactionToEdit?.name ?? "")”?")
        }
        .onAppear {
            if let transaction = transactionToEdit {
                fillData(from: transaction)
            }
        }
    }
    
    private var leadingToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var trailingToolbar: some ToolbarContent {
        if transactionToEdit != nil {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(
                        "Xoá",
                        systemImage: "trash",
                        role: .destructive
                    ) {
                        showDeleteConfirm = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
    }

    
    private var isFormValid: Bool {
        !transactionName.isEmpty &&
        !amount.isEmpty &&
        Double(amount) != nil &&
        selectedBudgetId != nil
    }
    
    private func fillData(from transaction: Transaction) {
        transactionName = transaction.name ?? ""
        
        amount = "\(Int(transaction.amount))"
        
        let dateFormatter = ISO8601DateFormatter()
        if let parsedDate = dateFormatter.date(from: transaction.date_time) {
            dateTime = parsedDate
        } else {
            dateTime = Date()
        }
        
        isRecurring = transaction.is_recurring ?? false
        
        if let startDateStr = transaction.recurring_start_date,
           let parsedStart = dateFormatter.date(from: startDateStr) {
            recurringStartDate = parsedStart
        } else {
            recurringStartDate = Date()
        }
        
        if let unit = transaction.recurring_interval_unit {
            recurringIntervalUnit = unit
        } else {
            recurringIntervalUnit = "month"
        }

        selectedCategoryId = transaction.category_id
        description = transaction.description ?? ""
        selectedBudgetId = transaction.budget_id
        selectedTypeDisplay = transaction.type == "income" ? "Nạp vào" : "Chi ra"
        
        if let imageUrlStr = transaction.image, !imageUrlStr.isEmpty, let url = URL(string: imageUrlStr) {
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: url),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        selectedImage = uiImage
                    }
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let amountDouble = Double(amount),
              let budgetId = selectedBudgetId else { return }
        
        let typeValue = typeOptions.first { $0.0 == selectedTypeDisplay }?.1 ?? "outcome"
        let dateFormatter = ISO8601DateFormatter()
        let isoDate = dateFormatter.string(from: dateTime)
        
        Task {
            do {
                var imageUrl: String? = nil
                
                if let selectedImage = selectedImage {
                    imageUrl = try await TransactionService.shared.uploadImage(selectedImage)
                    print("Uploaded image URL: \(imageUrl ?? "")")
                }
                
                let success: Bool
                
                let noteValue = description.isEmpty ? transactionName : description
                let categoryIdToSend = selectedCategoryId
                
                let isoDate = dateFormatter.string(from: dateTime)
                let recurringStartIso = isRecurring ? dateFormatter.string(from: recurringStartDate) : nil
                
                if let transaction = transactionToEdit {
                    _ = try await TransactionService.shared.updateTransaction(
                        id: transaction.id,
                        name: transactionName,
                        amount: amountDouble,
                        category_id: categoryIdToSend,
                        note: noteValue,
                        date: isoDate,
                        type: typeValue,
                        image: imageUrl,
                        is_recurring: isRecurring ? true : nil,
                        recurring_start_date: recurringStartIso,
                        recurring_interval_unit: isRecurring ? recurringIntervalUnit : nil,
                        recurring_interval_value: isRecurring ? 1 : nil
                    )
                    success = true
                } else {
                    _ = try await TransactionService.shared.createTransaction(
                        name: transactionName,
                        amount: amountDouble,
                        category_id: categoryIdToSend,
                        note: noteValue,
                        date: isoDate,
                        type: typeValue,
                        budget_id: budgetId,
                        image: imageUrl,
                        is_recurring: isRecurring ? true : nil,
                        recurring_start_date: recurringStartIso,
                        recurring_interval_unit: isRecurring ? recurringIntervalUnit : nil,
                        recurring_interval_value: isRecurring ? 1 : nil
                    )
                    success = true
                }
                
                if success {
                    onSuccess?()
                    dismiss()
                }
            } catch {
                print("Error saving transaction:", error)
            }
        }
    }
    
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

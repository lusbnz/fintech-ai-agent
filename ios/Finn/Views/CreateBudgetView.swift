import SwiftUI

struct CreateBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var budgetViewModel: BudgetViewModel
    @EnvironmentObject var settings: AppSettings
    @State private var keyboardHeight: CGFloat = 0
    
    let budget: Budget?
    let onSuccess: () -> Void
    
    @State private var budgetName: String = ""
    @State private var amount: String = ""
    @State private var recurring_topup_amount = ""
    @State private var dateTime: Date = Date()
    @State private var period: String = "1 Month"
    @State private var isRecurring: Bool = false
    
    let periods = ["1 Week", "1 Month", "3 Month"]
    
    private var isFormValid: Bool {
        !budgetName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !amount.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(amount) ?? 0 > 0
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "F04A25"), Color(hex: "FFFFFF")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.5)
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Spacer(minLength: 12)
                    
                    Text(budget == nil ? "Tạo ngân sách" : "Cập nhật ngân sách")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "636363"))
                    
                    TextField("Tên ngân sách", text: $budgetName)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: "636363"))
                        .padding(.vertical, 6)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(hex: "E0E0E0"))
                                .padding(.top, 40)
                        )
                        .padding(.horizontal)
                    
                    TextField("Số tiền", text: $amount)
                        .keyboardType(.decimalPad)
                        .padding()
                        .font(.system(size: 28, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(24)
                        .onTapGesture {
                        }
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                                    to: nil, from: nil, for: nil)
                                }
                            }
                        }
                    
                    Toggle(isOn: $isRecurring) {
                        HStack {
                            Image(systemName: "repeat")
                                .foregroundColor(Color(hex: "636363"))
                            Text("Nạp tiền định kỳ")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "636363"))
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(16)
                    
                    if isRecurring {
                        TextField("Nạp định kỳ", text: $recurring_topup_amount)
                            .keyboardType(.decimalPad)
                            .padding()
                            .font(.system(size: 28, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(24)
                            .onTapGesture {
                            }
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                                        to: nil, from: nil, for: nil)
                                    }
                                }
                            }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "636363"))
                                Text("Chu kì")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "636363"))
                            }
                            Text("Bao lâu thì bạn gia hạn ngân sách?")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "636363"))
                                .padding(.bottom, 8)
                            
                            Picker("Chu kì", selection: $period) {
                                ForEach(periods, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(16)
                        
                        infoRow(icon: "calendar", title: "Ngày bắt đầu") {
                            DatePicker("", selection: $dateTime, displayedComponents: [.date])
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Lần nạp tiếp theo:")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "636363"))
                            
                            Text(nextRefillDate().formatted(date: .numeric, time: .omitted))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(16)
                        .transition(.opacity)
                    }
                    
                    Spacer(minLength: 160)
                }
                .padding(.horizontal)
            }
            
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0.7), .white.opacity(0.9)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
                .blur(radius: 12)
            }
            .ignoresSafeArea(edges: .bottom)
            
            VStack {
                if keyboardHeight == 0 {
                    if budgetViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .frame(height: 48)
                    } else {
                        Button(action: createOrUpdateBudget) {
                            ZStack(alignment: .leading) {
                                Text(budget == nil ? "Tạo mới" : "Cập nhật")
                                    .font(.system(size: 14))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(
                                        RoundedRectangle(cornerRadius: 32)
                                            .fill(isFormValid ? Color.black.opacity(0.75) : Color.gray.opacity(0.5))
                                    )
                                
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
                        .disabled(!isFormValid || budgetViewModel.isLoading)
                    }
                }
                
                if let error = budgetViewModel.error {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if settings.isSettedFirstBudeget {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .hideKeyboardOnTap()
        .onAppear {
            if let budget = budget {
                budgetName = budget.name
                amount = String(budget.amount)
                dateTime = budget.start_date
                isRecurring = budget.recurring_active
                recurring_topup_amount = String(budget.recurring_topup_amount)
                let unit = budget.recurring_interval_unit.lowercased()
                let val = budget.recurring_interval_value
                if unit == "week" && val == 1 {
                    period = "1 Week"
                } else if unit == "month" && val == 1 {
                    period = "1 Month"
                } else if unit == "month" && val == 3 {
                    period = "3 Month"
                } else {
                    period = "1 Month"
                }
            }
        }
        .onKeyboardChange { height in
            withAnimation(.easeInOut(duration: 0.1)) {
                keyboardHeight = height
            }
        }
    }
    
    private func createOrUpdateBudget() {
        guard let amountValue = Double(amount) else { return }
        let recurringTopupAmountValue: Double? =
            isRecurring ? (Double(recurring_topup_amount) ?? 0) : 0
        
        var unit: String = "week"
        var intervalValue: Int = 1
        if isRecurring {
            switch period {
            case "1 Week":
                unit = "week"
                intervalValue = 1
            case "1 Month":
                unit = "month"
                intervalValue = 1
            case "3 Month":
                unit = "month"
                intervalValue = 3
            default:
                unit = "month"
                intervalValue = 1
            }
        }
        let active = isRecurring
        
        Task {
            let success: Bool
            if let budget = budget {
                success = await budgetViewModel.updateBudget(
                    id: budget.id,
                    name: budgetName,
                    amount: amountValue,
                    start_date: dateTime,
                    recurring_topup_amount: recurringTopupAmountValue ?? 0,
                    recurring_interval_unit: unit,
                    recurring_interval_value: intervalValue,
                    recurring_active: active,
                )
            } else {
                success = await budgetViewModel.createBudget(
                    name: budgetName,
                    amount: amountValue,
                    start_date: dateTime,
                    recurring_topup_amount: recurringTopupAmountValue ?? 0,
                    recurring_interval_unit: unit,
                    recurring_interval_value: intervalValue,
                    recurring_active: active,
                )
            }
            
            if success {
                onSuccess()
                dismiss()
            }
        }
    }
    
    private func nextRefillDate() -> Date {
        switch period {
        case "1 Week":    return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: dateTime) ?? dateTime
        case "1 Month":   return Calendar.current.date(byAdding: .month, value: 1, to: dateTime) ?? dateTime
        case "3 Month":   return Calendar.current.date(byAdding: .month, value: 3, to: dateTime) ?? dateTime
        default:          return dateTime
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
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
}

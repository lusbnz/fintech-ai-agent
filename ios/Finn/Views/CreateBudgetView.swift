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
    @State private var rawAmount: String = "" // Số thực không format
    @State private var recurring_topup_amount: String = ""
    @State private var rawRecurringAmount: String = "" // Số thực không format
    @State private var dateTime: Date = Date()
    @State private var period: String = "1 Month"
    @State private var isRecurring: Bool = false
    
    let periods = ["1 Week", "1 Month", "3 Month"]
    
    private let amountSuggestions = [".000", "0.000", "00.000"]
    
    private func formatNumber(_ value: String) -> String {
        let digits = value.filter { $0.isNumber }
        guard let number = Int(digits) else { return "" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: number)) ?? digits
    }
    
    private func parseNumber(_ formatted: String) -> String {
        return formatted.filter { $0.isNumber }
    }
    
    private var isFormValid: Bool {
        !budgetName.trimmingCharacters(in: .whitespaces).isEmpty
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
                        VStack(spacing: 12) {
                            HStack(spacing: 4) {
                                TextField("0", text: $recurring_topup_amount)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 28, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .onChange(of: recurring_topup_amount) { newValue in
                                        let digits = parseNumber(newValue)
                                        rawRecurringAmount = digits
                                        if !digits.isEmpty {
                                            recurring_topup_amount = formatNumber(digits)
                                        }
                                    }
                                
                                Text("VND")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "636363"))
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            
                            BudgetAmountSuggestionsView(
                                currentAmount: rawRecurringAmount,
                                suggestions: amountSuggestions
                            ) { suggestion in
                                let newAmount: String
                                if suggestion.hasPrefix(".") {
                                    newAmount = rawRecurringAmount + suggestion.filter { $0.isNumber }
                                } else if Int(suggestion) != nil {
                                    newAmount = suggestion
                                } else {
                                    let zeros = suggestion.filter { $0 == "0" }.count
                                    newAmount = rawRecurringAmount + String(repeating: "0", count: zeros)
                                }
                                rawRecurringAmount = newAmount
                                recurring_topup_amount = formatNumber(newAmount)
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
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Lần nạp tiếp theo")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "636363"))
                                
                                Text(nextRefillDate().formatted(date: .long, time: .omitted))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "636363"))
                        }
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
                
                let amountInt = Int(budget.amount)
                rawAmount = "\(amountInt)"
                amount = formatNumber("\(amountInt)")
                
                dateTime = budget.start_date
                isRecurring = budget.recurring_active
                
                let recurringInt = Int(budget.recurring_topup_amount)
                rawRecurringAmount = "\(recurringInt)"
                recurring_topup_amount = formatNumber("\(recurringInt)")
                
                let unit = budget.recurring_interval_unit!.lowercased()
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
        let recurringTopupAmountValue: Double? =
            isRecurring ? (Double(rawRecurringAmount) ?? 0) : 0
        
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
                    start_date: dateTime,
                    recurring_topup_amount: recurringTopupAmountValue ?? 0,
                    recurring_interval_unit: unit,
                    recurring_interval_value: intervalValue,
                    recurring_active: active
                )
            } else {
                success = await budgetViewModel.createBudget(
                    name: budgetName,
                    amount: active ? (recurringTopupAmountValue ?? 0) : 0,
                    start_date: dateTime,
                    recurring_topup_amount: recurringTopupAmountValue ?? 0,
                    recurring_interval_unit: unit,
                    recurring_interval_value: intervalValue,
                    recurring_active: active
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

struct BudgetAmountSuggestionsView: View {
    let currentAmount: String
    let suggestions: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        onSelect(suggestion)
                    } label: {
                        Text(previewAmount(suggestion))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func previewAmount(_ suggestion: String) -> String {
        if currentAmount.isEmpty {
            return suggestion
        }
        
        let zeros = suggestion.filter { $0 == "0" }.count
        let newAmount = currentAmount + String(repeating: "0", count: zeros)
        
        guard let number = Int(newAmount) else { return suggestion }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        
        return (formatter.string(from: NSNumber(value: number)) ?? newAmount) + " VND"
    }
    
    private func formatQuickAmount(_ value: String) -> String {
        guard let number = Int(value) else { return value }
        
        if number >= 1_000_000 {
            let millions = Double(number) / 1_000_000
            if millions.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(millions))M VND"
            } else {
                return String(format: "%.1fM VND", millions)
            }
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        
        return (formatter.string(from: NSNumber(value: number)) ?? value) + " VND"
    }
}

import SwiftUI

struct CreateBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = BudgetViewModel()
    
    let budget: Budget?
    let onSuccess: () -> Void
    
    @State private var budgetName: String = ""
    @State private var amount: String = ""
    @State private var dateTime: Date = Date()
    @State private var period: String = "1 Month"
    
    let periods = ["Single", "1 Week", "1 Month", "1 Year"]
    
    private var isFormValid: Bool {
        !budgetName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !amount.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(amount) ?? 0 > 0
    }
    
    let periodMap: [String: String] = [
        "single": "Single",
        "1_week": "1 Week",
        "1_month": "1 Month",
        "1_year": "1 Year"
    ]
    
    private func displayPeriod(from code: String) -> String {
        periodMap[code.lowercased()] ?? "Single"
    }

    private func codePeriod(from display: String) -> String {
        periodMap.first { $0.value == display }?.key ?? "single"
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
                    
                    Text(budget == nil ? "Create Budget" : "Update Budget")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "636363"))
                    
                    TextField("Budget Name", text: $budgetName)
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
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .padding()
                        .font(.system(size: 28, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(24)
                    
                    infoRow(icon: "calendar", title: "Datetime") {
                        DatePicker("", selection: $dateTime, displayedComponents: [.date])
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "636363"))
                            Text("Period")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "636363"))
                        }
                        Text("Select how long this budget lasts")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "636363"))
                            .padding(.bottom, 8)
                        
                        Picker("Period", selection: $period) {
                            ForEach(periods, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.segmented)
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
                    gradient: Gradient(colors: [.white.opacity(0.7), .white.opacity(0.9)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
                .blur(radius: 12)
            }
            .ignoresSafeArea(edges: .bottom)
            
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .frame(height: 48)
                } else {
                    Button(action: createOrUpdateBudget) {
                        ZStack(alignment: .leading) {
                            Text(budget == nil ? "Create" : "Update")
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
                                .background(Circle().fill(Color.black))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .disabled(!isFormValid || viewModel.isLoading)
                }
                
                if let error = viewModel.error {
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
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            if let budget = budget {
                budgetName = budget.name
                amount = String(budget.amount)
                dateTime = budget.start_date
                period = displayPeriod(from: budget.period)
            }
        }
    }
    
    private func createOrUpdateBudget() {
        guard let amountValue = Double(amount) else { return }
        
        Task {
            let success: Bool
            if let budget = budget {
                success = await viewModel.updateBudget(
                    id: budget.id,
                    name: budgetName,
                    amount: amountValue,
                    start_date: dateTime,
                    period: period
                )
            } else {
                success = await viewModel.createBudget(
                    name: budgetName,
                    amount: amountValue,
                    start_date: dateTime,
                    period: period
                )
            }
            
            if success {
                onSuccess()
                dismiss()
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
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
}

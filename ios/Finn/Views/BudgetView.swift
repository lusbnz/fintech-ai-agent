import SwiftUI
import Combine

struct BudgetView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    @EnvironmentObject var budgetViewModel: BudgetViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showCreateNew = false
    
    private var userCurrency: String {
        app.profile?.currency ?? "VNĐ"
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "F04A25"),
                    Color(hex: "FFFFFF")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.5)
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    Text("Ngân sách")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Spacer().frame(width: 16)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Button {
                    showCreateNew = true
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .frame(height: 44)
                        
                        HStack {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                            Text("Tạo mới")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

                if budgetViewModel.isLoading {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(0..<3) { _ in
                                SkeletonItem()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .disabled(true)
                } else if let error = budgetViewModel.error {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 32))
                            .foregroundColor(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Thử lại") {
                            Task { await budgetViewModel.loadBudgets() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if app.budgets.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text("Không có ngân sách nào")
                            .font(.headline)
                        Text("Bấm 'Tạo mới' để bắt đầu")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(app.budgets) { budget in
                                NavigationLink {
                                    BudgetDetailView(budget: budget)
                                } label: {
                                    BudgetItem(
                                        budget: budget,
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showCreateNew) {
            NavigationStack {
                CreateBudgetView(
                    budget: nil, onSuccess: {
                    }
                )
                .onDisappear {
                    Task { await budgetViewModel.loadBudgets() }
                }
            }
        }
        .refreshable {
            await budgetViewModel.loadBudgets()
        }
        .onChange(of: userCurrency) { oldValue, newValue in
            guard oldValue != newValue else { return }
            budgetViewModel.objectWillChange.send()
        }
    }
}

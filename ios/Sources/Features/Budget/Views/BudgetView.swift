import SwiftUI
import Combine

struct BudgetView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showCreateNew = false
    @StateObject private var viewModel = BudgetViewModel()
    
    private var userCurrency: String? {
        authViewModel.userProfile?.currency
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
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    
                    Spacer()
                    Text("Your Budget")
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
                            Text("Create New")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

                if viewModel.isLoading {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(0..<1) { _ in
                                SkeletonListItem()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .disabled(true)
                } else if let error = viewModel.error {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 32))
                            .foregroundColor(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await viewModel.loadBudgets() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.budgets.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text("No budgets yet")
                            .font(.headline)
                        Text("Tap 'Create New' to get started")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(viewModel.budgets) { budget in
                                NavigationLink {
                                    BudgetDetailView(budget: budget)
                                        .environmentObject(authViewModel)
                                        .environmentObject(transactionViewModel)
                                } label: {
                                    BudgetItem(
                                        title: budget.name,
                                        remain: budget.formattedAmount(using: userCurrency)
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
                    Task { await viewModel.loadBudgets() }
                }
            }
        }
        .task {
            await viewModel.loadBudgets()
        }
        .refreshable {
            await viewModel.loadBudgets()
        }
        .onChange(of: userCurrency) { oldValue, newValue in
            guard oldValue != newValue else { return }
            viewModel.objectWillChange.send()
        }
    }
}

struct BudgetItem: View {
    let title: String
    let remain: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                Text("Remain: \(remain)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

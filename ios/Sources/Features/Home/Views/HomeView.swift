import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var transactionVM: TransactionViewModel
    @EnvironmentObject var budgetViewModel: BudgetViewModel
    @State private var showCreateNew = false
    @State private var showQRScanner = false
    @State private var scannedCode: String?
    
    @State private var selectedType: String = "All"
    let types = ["All", "Income", "Outgoing"]
    
    private var latestTransactions: [Transaction] {
        var filtered = transactionVM.transactions

        switch selectedType {
        case "Income":
            filtered = filtered.filter { $0.type.lowercased() == "income" }
        case "Outgoing":
            filtered = filtered.filter { $0.type.lowercased() == "outcome" || $0.type.lowercased() == "expense" }
        default:
            break
        }

        return filtered.sorted { ($0.date_time) > ($1.date_time) }.prefix(5).map { $0 }
    }

    
    private func sortDates(_ d1: String, _ d2: String) -> Bool {
        if d1 == "Today" { return true }
        if d2 == "Today" { return false }
        return d1 > d2
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "CFDBF8"),
                    Color(hex: "FFFFFF")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.3)
            .ignoresSafeArea()

            ScrollView {
                VStack{
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hi, \(authViewModel.userProfile?.display_name ?? "Guest")!")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.black)

                            Text("Sun, October 15")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
//                            Button(action: {
//                                showQRScanner = true
//                            }) {
//                                Image(systemName: "qrcode.viewfinder")
//                                    .font(.system(size: 16))
//                                    .foregroundColor(.black)
//                                    .padding(6)
//                                    .background(Color.white)
//                                    .clipShape(Circle())
//                                    .shadow(radius: 2)
//                            }
//                            .fullScreenCover(isPresented: $showQRScanner) {
//                                QRCodeScannerView { result in
//                                    scannedCode = result
//                                    showQRScanner = false
//                                    print("Scanned QR Code:", result)
//                                }
//                                .ignoresSafeArea()
//                            }
                            
                            NavigationLink {
                                SettingView(authViewModel: authViewModel)
                            } label: {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .padding(6)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if let budget = budgetViewModel.budgets.first {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(budget.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("\(Int(budget.remain).formattedWithSeparator) VNĐ")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Left to spend of \(Int(budget.limit).formattedWithSeparator) VNĐ limit")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            
                            HStack {
                                Text("\(Int(budget.days_remaining)) days to go")
                                    .font(.system(size: 12))
                                    .foregroundColor(.black)
                                Spacer()
                                Text("\(Int(-budget.diff_avg).formattedWithSeparator) saved")
                                    .font(.system(size: 12))
                                    .foregroundColor(.black)
                            }
                            
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)
                                Capsule()
                                    .fill(Color.blue)
                                    .frame(width: CGFloat(budget.progress) * 200, height: 6)
                            }
                            
                            HStack(spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text("\(Int(budget.total_income).formattedWithSeparator) VNĐ")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("Incoming")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(16)
                                
                                VStack(alignment: .leading) {
                                    Text("\(Int(budget.total_outcome).formattedWithSeparator) VNĐ")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("Outgoing")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(16)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    HStack(alignment: .center) {
                        FlexibleView(data: types) { tag in
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedType = tag
                                }
                            } label: {
                                Text(tag)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(selectedType == tag ? .black : .gray)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(selectedType == tag ? Color.white : Color.gray.opacity(0.2))
                                    )
                                    .shadow(color: selectedType == tag ? Color.white.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                            }
                        }
                   }
                   .padding(.horizontal)
                   .padding(.top, 4)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack() {
                            Text("Lastest Transaction")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                     
                        if latestTransactions.isEmpty {
                            Text("No transactions found")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 16)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(latestTransactions) { tx in
                                    NavigationLink(destination: TransactionDetailView(transaction: tx)) {
                                        TransactionItem(
                                            title: tx.name,
                                            remain: tx.type == "outcome"
                                                ? "-\(Int(abs(tx.amount)).formattedWithSeparator) VNĐ"
                                                : "+\(Int(tx.amount).formattedWithSeparator) VNĐ",
                                            time: tx.formattedDate,
                                            place: (tx.location?.name.isEmpty == false ? tx.location!.name : "Unknown"),
                                            attachments: tx.image != nil ? 1 : 0,
                                            categoryColor: tx.type == "income" ? .green : .red,
                                            categoryIcon: tx.type == "income" ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 40)
                    .padding(.top, 20)
                }
            }
        }
        .navigationTitle("Home")
        .fullScreenCover(isPresented: $showCreateNew) {
            NavigationStack {
                CreateTransactionView()
            }
        }
        .task {
            await budgetViewModel.loadBudgets()
            await transactionVM.refresh()
        }
    }
}

extension Numeric {
    var formattedWithSeparator: String {
        Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        return formatter
    }()
}

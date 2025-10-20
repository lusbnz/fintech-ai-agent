import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showCreateNew = false
    @State private var showQRScanner = false
    @State private var scannedCode: String?
    
    @State private var selectedBudget: String = "All"
    let budgets = ["All", "Income", "Outgoing"]
    
    var groupedTransactions: [String: [Transaction]] = [
        "Today": [
            Transaction(
                title: "Shopping",
                amount: "-20,000 VNĐ",
                time: "14:30",
                place: "Trung Yên",
                attachments: 1,
                categoryIcon: "bag.fill",
                categoryColor: .orange
            )
        ],
        "Fri, Aug 30": [
            Transaction(
                title: "Groceries",
                amount: "-120,000 VNĐ",
                time: "16:00",
                place: "Vinmart",
                attachments: 2,
                categoryIcon: "cart.fill",
                categoryColor: .green
            )
        ]
    ]
    
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
                            Button(action: {
                                showQRScanner = true
                            }) {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .padding(6)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .fullScreenCover(isPresented: $showQRScanner) {
                                QRCodeScannerView { result in
                                    scannedCode = result
                                    showQRScanner = false
                                    print("Scanned QR Code:", result)
                                }
                                .ignoresSafeArea()
                            }

                            
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
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Budget Shopping")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text("$68.70")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Left to spend of $500 limit")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                        
                        HStack {
                            Text("1 day to go")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                            Spacer()
                            Text("$233.00 saved")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                        }
                        
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                            Capsule()
                                .fill(Color.blue)
                                .frame(width: 180, height: 6)
                        }
                        
                        HStack(spacing: 8) {
                            VStack(alignment: .leading) {
                                Text("$567.00")
                                    .font(.system(size: 20, weight: .semibold))
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
                                Text("$234.00")
                                    .font(.system(size: 20, weight: .semibold))
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
                    
//                    VStack(alignment: .leading, spacing: 0) {
//                        VStack(spacing: 12) {
//                            HStack {
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text("Spendly Smarter with AI")
//                                        .font(.system(size: 20, weight: .bold))
//                                        .foregroundColor(.white)
//                                    Text("3 more transaction to get 20 prompt")
//                                        .font(.system(size: 14, weight: .medium))
//                                        .foregroundColor(.white)
//                                }
//
//                                Spacer()
//                                
//                                Image(systemName: "banknote")
//                                    .font(.system(size: 20))
//                                    .rotationEffect(.degrees(-10))
//
//                            }
//                            .padding(.horizontal)
//                            .padding(.vertical, 16)
//                            .background(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [
//                                        Color(hex: "614AB8"),
//                                        Color(hex: "508ED0")
//                                    ]),
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                            )
//                            .cornerRadius(24)
//                        }
//                    }
//                    .padding()
                    
                    HStack(alignment: .center) {
                        FlexibleView(data: budgets) { tag in
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedBudget = tag
                                }
                            } label: {
                                Text(tag)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(selectedBudget == tag ? .black : .gray)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(selectedBudget == tag ? Color.white : Color.gray.opacity(0.2))
                                    )
                                    .shadow(color: selectedBudget == tag ? Color.white.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
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
                        
                        ForEach(groupedTransactions.keys.sorted(by: sortDates), id: \.self) { key in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(key)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                    
                                    if let transactions = groupedTransactions[key], !transactions.isEmpty {
                                        HStack(spacing: 12) {
                                            let totalAmount = transactions.reduce(0) { sum, transaction in
                                                let amountStr = transaction.amount.replacingOccurrences(of: "[^0-9-]", with: "", options: .regularExpression)
                                                return sum + (Int(amountStr) ?? 0)
                                            }
                                            Text("\(totalAmount.formattedWithSeparator) VNĐ")
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(totalAmount < 0 ? Color.red : Color.green)
                                                .cornerRadius(8)
                                            
                                            Button(action: { showCreateNew = true }) {
                                                Image(systemName: "plus.circle")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                
                                VStack(spacing: 8) {
                                    ForEach(groupedTransactions[key] ?? []) { transaction in
                                        NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                                            TransactionItem(
                                                title: transaction.title,
                                                remain: transaction.amount,
                                                time: transaction.time,
                                                place: transaction.place,
                                                attachments: transaction.attachments,
                                                categoryColor: transaction.categoryColor,
                                                categoryIcon: transaction.categoryIcon
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Text("No more transactions")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 16)
                    }
                    .padding(.bottom, 40)
                    .padding(.top, 20)
                }
            }
        }
        .task {
            await authViewModel.fetchProfile()
        }
        .navigationTitle("Home")
        .fullScreenCover(isPresented: $showCreateNew) {
            NavigationStack {
                CreateTransactionView()
            }
        }
    }
}

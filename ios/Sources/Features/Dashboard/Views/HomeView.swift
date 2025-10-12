import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showCreateNew = false
    @State private var showQRScanner = false
    @State private var scannedCode: String?
    
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
                        Text("Hi, \(authViewModel.userProfile?.display_name ?? "Guest")!")
                            .font(.system(size: 24, weight: .semibold))
                        
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
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Insight")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("4/9998")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                            
                            TabView {
                                InsightChartCard(
                                    spendingData: [
                                        .init(category: "Shopping", value: 20, color: .blue),
                                        .init(category: "Food", value: 30, color: .orange),
                                        .init(category: "Bills", value: 25, color: .green),
                                        .init(category: "Entertainment", value: 25, color: .purple)
                                    ],
                                    index: 1,
                                    total: 3,
                                    title: "Phân loại thu chi",
                                    highlightText: "cho mua sắm",
                                    highlightValue: "20%",
                                    icon: "bag.fill",
                                    iconColor: .blue,
                                    chartType: .pie
                                )

                                InsightChartCard(
                                    spendingData: [
                                        .init(category: "Tháng 8", value: 50, color: .green),
                                        .init(category: "Tháng 9", value: 65, color: .orange),
                                        .init(category: "Tháng 10", value: 80, color: .blue)
                                    ],
                                    index: 2,
                                    total: 3,
                                    title: "Chi tiêu theo tháng",
                                    highlightText: "so với tháng trước",
                                    highlightValue: "+15%",
                                    icon: "chart.line.uptrend.xyaxis",
                                    iconColor: .green,
                                    chartType: .bar
                                )

                                InsightChartCard(
                                    spendingData: [
                                        .init(category: "Food", value: 40, color: .orange),
                                        .init(category: "Bills", value: 20, color: .green),
                                        .init(category: "Travel", value: 40, color: .purple)
                                    ],
                                    index: 3,
                                    total: 3,
                                    title: "Tỷ lệ tiết kiệm",
                                    highlightText: "tốt hơn 30%",
                                    highlightValue: "↑",
                                    icon: "chart.donut.fill",
                                    iconColor: .purple,
                                    chartType: .line
                                )
                            }
                            .tabViewStyle(.page(indexDisplayMode: .automatic))
                            .indexViewStyle(.page(backgroundDisplayMode: .automatic))
                            .frame(height: 240)

                            VStack(spacing: 12) {
                                HStack(spacing: 24) {
                                    VStack {
                                        Image(systemName: "leaf.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.green)
                                        Text("9998")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.black)
                                        Text("Prompt")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Image(systemName: "square.stack.3d.up.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.blue)
                                        Text("$650")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.black)
                                        Text("Remain")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Image(systemName: "cloud.rain.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.red)
                                        Text("$210")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.black)
                                        Text("Expense")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white)
                                        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                                )

                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("3 more transaction to get")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                        Text("20 prompt")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                    }

                                    Spacer()

                                    Image(systemName: "banknote.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .rotationEffect(.degrees(-10))
                                }
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "614AB8"),
                                            Color(hex: "B4A5EC")
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .opacity(0.5)
                                )
                                .cornerRadius(24)
                            }
                        }
                        .padding(.horizontal)
                        
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

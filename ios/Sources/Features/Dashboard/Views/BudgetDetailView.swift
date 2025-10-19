import SwiftUI

struct BudgetDetailView: View {
    let title: String
    let remain: String
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showCreateNew = false
    @State private var currentWeekOffset = 0
    @State private var selectedBudget: String = "All"
    @State private var showWeekPicker = false
    @State private var selectedDate = Date()
    
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
            
            
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        Spacer()
                        Menu {
                            Button("Edit", systemImage: "pencil") { }
                            Button("Delete", systemImage: "trash", role: .destructive) { }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Shopping")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.black)
                        Text("64 Items")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

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

                   Spacer()
               }
               .padding(.horizontal)
               .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 24) {
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
        .navigationBarBackButtonHidden(true)
    }
    
    private func sortDates(_ d1: String, _ d2: String) -> Bool {
        if d1 == "Today" { return true }
        if d2 == "Today" { return false }
        return d1 > d2
    }
}

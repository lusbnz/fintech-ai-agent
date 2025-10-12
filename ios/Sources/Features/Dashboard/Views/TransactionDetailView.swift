import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("Transaction Detail")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Spacer().frame(width: 24)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(transaction.categoryColor.opacity(0.2))
                        .frame(width: 64, height: 64)
                    Image(systemName: transaction.categoryIcon)
                        .font(.system(size: 28))
                        .foregroundColor(transaction.categoryColor)
                }

                Text(transaction.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(transaction.amount)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(transaction.amount.contains("-") ? .red : .green)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "clock")
                        Text(transaction.time)
                    }
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(transaction.place)
                    }
                    if transaction.attachments > 0 {
                        HStack {
                            Image(systemName: "paperclip")
                            Text("\(transaction.attachments) Attachment\(transaction.attachments > 1 ? "s" : "")")
                        }
                    }
                }
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.1), radius: 4)
                
                Spacer()
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "CFDBF8"), Color(hex: "FFFFFF")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

import SwiftUI

struct TransactionReccurringItem: View {
    let title: String
    let remain: String
    var time: String
    var attachments: Int
    var categoryColor: Color = .blue
    var categoryIcon: String = "cart.fill"
    var lastRun: String?
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: categoryIcon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(categoryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
                
                if lastRun != nil {
                    HStack(spacing: 6) {
                        Text("Lần cuối: \(lastRun!)")
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                }
                else {
                    HStack(spacing: 6) {
                        Text(time)
                        if attachments > 0 {
                            Text("•")
                            Text("\(attachments) ảnh")
                        }
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(remain)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(remain.contains("-") ? .red : .green)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }
}

import SwiftUI

// MARK: - Model

enum NotificationStatus {
    case detected
    case processing
    case preview
    case recorded
}

struct BankNotification: Identifiable {
    let id = UUID()
    let package: String
    let title: String
    let rawText: String
    
    var status: NotificationStatus = .detected
    
    var amount: Double?
    var category: String = ""
    var note: String = ""
}

struct BankNotificationsView: View {
    
    @State private var notifications: [BankNotification] = [
        BankNotification(
            package: "com.mbmobile",
            title: "Thông báo biến động số dư",
            rawText: "TK 03xxx814|GD: +5,000VND 30/12/25 01:13 |SD: ******** VND|ND: NGUYEN DUY HUNG chuyen tien"
        )
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($notifications) { $noti in
                    notificationRow(noti: $noti)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Thông báo ngân hàng")
            .background(Color(.systemGroupedBackground))
        }
        .preferredColorScheme(.light)
    }
    
    @ViewBuilder
    func notificationRow(noti: Binding<BankNotification>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(noti.wrappedValue.title)
                .font(.body.weight(.medium))
            
            Text(noti.wrappedValue.rawText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(noti.wrappedValue.status == .preview ? nil : 2)
            
            switch noti.wrappedValue.status {
            case .detected:
                recordButton(noti)
                
            case .processing:
                processingView
                
            case .preview:
                previewView(noti)
                
            case .recorded:
                recordedView
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .animation(.easeInOut, value: noti.wrappedValue.status)
    }
    
    func recordButton(_ noti: Binding<BankNotification>) -> some View {
        Button {
            startProcessing(noti)
        } label: {
            Text("Ghi nhận")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(.blue.opacity(0.12))
                .foregroundStyle(.blue)
                .clipShape(Capsule())
        }
    }
    
    var processingView: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Đang phân tích giao dịch…")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    func previewView(_ noti: Binding<BankNotification>) -> some View {
        VStack(spacing: 12) {
            
            OutcomeCardView(
                amount: abs(noti.wrappedValue.amount ?? 0),
                description: noti.wrappedValue.note
            )
        }
    }
    
    var recordedView: some View {
        Label("Đã ghi nhận", systemImage: "checkmark")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    
    struct OutcomeCardView: View {
        let amount: Double
        let description: String

        private var formattedAmount: String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = "."
            return formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.red)
                    
                    Text("Chi tiêu")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Text("-\(formattedAmount) VND")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.red)
                }
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }

    func startProcessing(_ noti: Binding<BankNotification>) {
        noti.status.wrappedValue = .processing
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            noti.amount.wrappedValue = 5000
            noti.category.wrappedValue = "Chuyển khoản"
            noti.note.wrappedValue = "Nguyễn Duy Hưng chuyển tiền"
            noti.status.wrappedValue = .preview
        }
    }
}

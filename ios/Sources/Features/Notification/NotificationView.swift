import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Fake data theo đúng các loại bạn liệt kê
    static let sampleNotifications = [
        NotificationItem(
            id: UUID(),
            title: "Giao dịch mới",
            message: "Bạn vừa thêm giao dịch “Cà phê Highlands” -250.000 ₫",
            timestamp: Date().addingTimeInterval(-300),
            type: .transaction,
            isRead: false
        ),
        NotificationItem(
            id: UUID(),
            title: "Vượt 90% ngân sách Ăn uống",
            message: "Bạn đã dùng 92% ngân sách tuần này. Hãy cân nhắc nhé!",
            timestamp: Date().addingTimeInterval(-3600*2),
            type: .budget,
            isRead: false
        ),
        NotificationItem(
            id: UUID(),
            title: "Morning Brief ☀️",
            message: "Hôm qua bạn chi 485.000 ₫ • Còn lại 3.200.000 ₫ cho hôm nay",
            timestamp: Date().addingTimeInterval(-3600*5),
            type: .daily,
            isRead: true
        ),
        NotificationItem(
            id: UUID(),
            title: "Đạt 50% mục tiêu tiết kiệm",
            message: "Chúc mừng! Bạn đã tiết kiệm được 5.000.000 ₫ / 10 triệu",
            timestamp: Date().addingTimeInterval(-86400*2),
            type: .goal,
            isRead: true
        ),
        NotificationItem(
            id: UUID(),
            title: "AI gợi ý",
            message: "Chi tiêu ăn ngoài tuần này tăng 42%. Có thể giảm xuống để đạt mục tiêu sớm hơn.",
            timestamp: Date().addingTimeInterval(-86400*3),
            type: .ai,
            isRead: false
        ),
        NotificationItem(
            id: UUID(),
            title: "7 ngày ghi chép liên tục!",
            message: "Tuyệt vời! Bạn đang duy trì thói quen tài chính rất tốt 🎉",
            timestamp: Date().addingTimeInterval(-86400*5),
            type: .engagement,
            isRead: true
        ),
        NotificationItem(
            id: UUID(),
            title: "Đăng nhập thiết bị mới",
            message: "iPhone 16 Pro • Hà Nội • 21:34, 21/11/2025",
            timestamp: Date().addingTime-interval(-86400*7),
            type: .security,
            isRead: true
        ),
        NotificationItem(
            id: UUID(),
            title: "Bản cập nhật mới",
            message: "Phiên bản 2.4.0 – Thêm báo cáo chi tiết theo tuần",
            timestamp: Date().addingTimeInterval(-86400*10),
            type: .system,
            isRead: true
        )
    ]
    
    @State private var notifications = sampleNotifications.sorted { $0.timestamp > $1.timestamp }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background hiện đại kiểu liquid glass
                LinearGradient(
                    colors: [Color(hex: "E6F0FF"), Color.white.opacity(0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if notifications.isEmpty {
                    emptyState
                } else {
                    listView
                }
            }
            .navigationTitle("Thông báo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Đóng") { dismiss() }
                        .fontWeight(.medium)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đánh dấu tất cả đã đọc") {
                        withAnimation {
                            notifications.indices.forEach { notifications[$0].isRead = true }
                        }
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var listView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(groupedByDate, id: \.0) { dateKey, items in
                    Section {
                        ForEach(items) { noti in
                            NotificationRow(item: noti)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                        }
                    } header: {
                        Text(dateHeader(for: dateKey))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            .padding(.top, 20)
                            .padding(.bottom, 8)
                            .background(Color(.systemBackground))
                    }
                }
            }
            .padding(.top, 8)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 56))
                .foregroundColor(.gray.opacity(0.5))
            Text("Chưa có thông báo nào")
                .font(.title3)
                .fontWeight(.medium)
            Text("Chúng tôi sẽ thông báo khi có cập nhật quan trọng")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Group by date
    private var groupedByDate: [(Date, [NotificationItem])] {
        Dictionary(grouping: notifications) { noti in
            Calendar.current.startOfDay(for: noti.timestamp)
        }
        .sorted { $0.key > $1.key }
    }
    
    private func dateHeader(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Hôm nay"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Hôm qua"
        } else {
            return date.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "vi_VN")))
        }
    }
}

// MARK: - Model
struct NotificationItem: Identifiable {
    let id: UUID
    let title: String
    let message: String
    let timestamp: Date
    let type: NotiType
    var isRead: Bool
}

enum NotiType {
    case transaction, budget, daily, goal, ai, engagement, security, system
    
    var icon: String {
        switch self {
        case .transaction: return "creditcard"
        case .budget:      return "chart.pie.fill"
        case .daily:       return "sun.max.fill"
        case .goal:        return "target"
        case .ai:          return "brain.head.profile"
        case .engagement:  return "star.fill"
        case .security:    return "lock.shield"
        case .system:      return "gearshape.fill"
        }
    }
    
    var tint: Color {
        switch self {
        case .budget:      return .orange
        case .goal:        return .purple
        case .ai:          return .blue
        case .engagement:  return .pink
        case .security:    return .red
        default:           return .primary
        }
    }
}

// MARK: - Row
struct NotificationRow: View {
    let item: NotificationItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.type.icon)
                .font(.system(size: 20))
                .foregroundColor(item.type.tint)
                .frame(width: 36, height: 36)
                .background(item.type.tint.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(item.message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(item.timestamp, style: .relative)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if !item.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 9, height: 9)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: item.isRead ? .clear : Color.blue.opacity(0.15), radius: 6, y: 3)
        )
        .background(
            // Liquid glass effect
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .blur(radius: 1)
        )
        .padding(.vertical, 4)
        .opacity(item.isRead ? 0.85 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: item.isRead)
    }
}

#Preview {
    NotificationView()
}
import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var app: AppState
    
    @StateObject private var viewModel = NotiViewModel()
    
    @State private var selectedTab = 0
    
    private var notifications: [Noti] {
        app.noti
    }
    
    private var filteredNotifications: [Noti] {
        selectedTab == 1 ? notifications.filter { !($0.is_read ?? false) } : notifications
    }
    
    private var unreadCount: Int {
        notifications.filter { !($0.is_read ?? false) }.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            if viewModel.isLoading && notifications.isEmpty {
                loadingView
            } else if filteredNotifications.isEmpty {
                emptyView
            } else {
                listView
            }
        }
        .background(Color(.systemGray6))
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadNoti(page: 1, append: false)
        }
        .onReceive(viewModel.$noti) { newNoti in
            app.noti = newNoti
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Navigation Bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                }
                
                Spacer()
                
                Text("Thông báo")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            HStack(spacing: 8) {
                TabButton(
                    title: "Tất cả",
                    count: viewModel.totalNotifications,
                    isSelected: selectedTab == 0
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = 0
                    }
                }
                
                TabButton(
                    title: "Chưa đọc",
                    count: unreadCount,
                    isSelected: selectedTab == 1,
                    showBadge: unreadCount > 0
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = 1
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(Color(.systemGray6))
    }
    
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(groupedNotifications, id: \.0) { date, items in
                    Section {
                        VStack(spacing: 8) {
                            ForEach(items) { noti in
                                NotificationCard(noti: noti) {
                                    if !(noti.is_read ?? false) {
                                        Task {
                                            await viewModel.updateNoti(id: noti.id, is_read: true)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    } header: {
                        HStack {
                            Text(dateHeader(date))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                    }
                }
                
                if viewModel.isLoading && !viewModel.noti.isEmpty {
                    ProgressView()
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                
                if viewModel.hasMorePages && !viewModel.isLoading {
                    Color.clear
                        .frame(height: 20)
                        .onAppear {
                            Task {
                                let nextPage = viewModel.currentPage + 1
                                await viewModel.loadNoti(page: nextPage, append: true)
                            }
                        }
                }
                
                if !viewModel.hasMorePages && !viewModel.noti.isEmpty {
                    Text("Đã tải hết thông báo")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                        .padding()
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 100)
        }
        .refreshable {
            await viewModel.loadNoti(page: 1, append: false)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "bell.slash")
                    .font(.system(size: 40))
                    .foregroundColor(.gray.opacity(0.5))
            }
            
            VStack(spacing: 6) {
                Text(selectedTab == 0 ? "Chưa có thông báo" : "Không có thông báo chưa đọc")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Các cập nhật sẽ xuất hiện ở đây")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Đang tải...")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var groupedNotifications: [(Date, [Noti])] {
        Dictionary(grouping: filteredNotifications) {
            Calendar.current.startOfDay(for: $0.createdAt)
        }
        .sorted { $0.key > $1.key }
        .map { ($0.key, $0.value.sorted { $0.createdAt > $1.createdAt }) }
    }
    
    private func dateHeader(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Hôm nay" }
        if Calendar.current.isDateInYesterday(date) { return "Hôm qua" }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: date).capitalized
    }
    
}

struct TabButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    var showBadge: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                
                if showBadge && !isSelected {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.red))
                } else if isSelected {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            .foregroundColor(isSelected ? .white : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.black : Color.white)
            )
            .shadow(color: isSelected ? .black.opacity(0.1) : .black.opacity(0.04), radius: 4, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NotificationCard: View {
    let noti: Noti
    let onTap: () -> Void
    
    private var isRead: Bool { noti.is_read ?? false }
    
    private var notiType: NotiType {
        switch noti.type {
        case "transaction_created":
            return .transactionCreated
        case "transaction_updated":
            return .transactionUpdated
        case "budget_created":
            return .budgetCreated
        case "budget_threshold_reached":
            return .budgetWarning
        case "budget_period_end":
            return .budgetEnd
        default:
            return .system
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(notiType.backgroundColor)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: notiType.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(notiType.iconColor)
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(noti.title ?? "Thông báo")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if !isRead {
                            Circle()
                                .fill(notiType.iconColor)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    if let description = noti.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    HStack(spacing: 8) {
                        Text(noti.createdAt, style: .relative)
                            .font(.system(size: 12))
                        
                        if let amount = noti.metaDouble("amount") {
                            let type = noti.metaString("type")
                            Text((type == "income" ? "+" : "-") + formatAmount(amount))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(type == "income" ? .green : .red)
                        }
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isRead ? Color.clear : notiType.iconColor.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return (formatter.string(from: NSNumber(value: value)) ?? "0") + " VND"
    }
}

enum NotiType {
    case transactionCreated
    case transactionUpdated
    case budgetCreated
    case budgetWarning
    case budgetEnd
    case system
    
    var icon: String {
        switch self {
        case .transactionCreated: return "plus.circle.fill"
        case .transactionUpdated: return "pencil.circle.fill"
        case .budgetCreated: return "dollarsign.circle.fill"
        case .budgetWarning: return "exclamationmark.triangle.fill"
        case .budgetEnd: return "calendar.badge.clock"
        case .system: return "bell.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .transactionCreated: return .blue
        case .transactionUpdated: return .orange
        case .budgetCreated: return .green
        case .budgetWarning: return .red
        case .budgetEnd: return .purple
        case .system: return .gray
        }
    }
    
    var backgroundColor: Color {
        iconColor.opacity(0.12)
    }
}

extension Noti {
    var createdAt: Date {
        guard let isoString = self.created_at else { return Date() }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: isoString) ?? Date()
    }
}

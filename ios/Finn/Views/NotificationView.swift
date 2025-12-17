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
        selectedTab == 1 ? notifications.filter { !(($0.is_read ?? false)) } : notifications
    }
    
    private var unreadCount: Int {
        notifications.filter { !(($0.is_read ?? false)) }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                
                if filteredNotifications.isEmpty {
                    emptyView
                } else {
                    listView
                }
            }
            .navigationBarBackButtonHidden(true)
            .background(Color(.systemGroupedBackground))
            .task {
                await viewModel.loadNoti(page: 1, append: false)
            }
            .onReceive(viewModel.$noti) { newNoti in
                app.noti = newNoti
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                Text("Thông báo")
                    .font(.system(size: 19, weight: .semibold))
                Spacer()
                
                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 16)
            
            HStack(spacing: 12) {
                tabButton("Tất cả", tag: 0)
                tabButton("Chưa đọc", tag: 1, badge: unreadCount > 0 && selectedTab != 1)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private func tabButton(_ title: String, tag: Int, badge: Bool = false) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tag
            }
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: selectedTab == tag ? .semibold : .medium))
                    .foregroundColor(selectedTab == tag ? .white : .gray)
                
                if badge {
                    Text("\(unreadCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .frame(height: 17)
                        .background(Color.black)
                        .cornerRadius(8.5)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(selectedTab == tag ? Color.black : Color.clear)
            )
        }
    }
    
    private var listView: some View {
        List {
            ForEach(groupedNotifications, id: \.0) { date, items in
                Section {
                    ForEach(items) { noti in
                        NotificationRow(noti: noti) {
                            if !(noti.is_read ?? false) {
                                Task {
                                    let success = await viewModel.updateNoti(id: noti.id, is_read: true)
                                    if success {
                                    }
                                }
                            }
                        }
                        .listRowInsets(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.systemGroupedBackground))
                    }
                } header: {
                    Text(dateHeader(date))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(.leading, 6)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            await viewModel.loadNoti(page: 1, append: false)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 18) {
            Image(systemName: "bell.slash")
                .font(.system(size: 56))
                .foregroundColor(.gray.opacity(0.4))
            
            Text(selectedTab == 0 ? "Chưa có thông báo" : "Không có thông báo chưa đọc")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("Các cập nhật sẽ xuất hiện ở đây")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var groupedNotifications: [(Date, [Noti])] {
        Dictionary(grouping: filteredNotifications) {
            Calendar.current.startOfDay(for: $0.createdAt ?? Date())
        }
        .sorted { $0.key > $1.key }
        .map { ($0.key, $0.value.sorted { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) }) }
    }
    
    private func dateHeader(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Hôm nay" }
        if Calendar.current.isDateInYesterday(date) { return "Hôm qua" }
        return date.formatted(.dateTime.day().month(.wide))
    }
}

struct NotificationRow: View {
    let noti: Noti
    let onTap: () -> Void
    
    private var isRead: Bool { noti.is_read ?? false }
    private var timestamp: Date { noti.createdAt ?? Date() }
    
    private var type: NotiType {
        switch noti.type {
        case "transaction": return .transaction
        case "budget": return .budget
        case "daily": return .daily
        case "goal": return .goal
        case "ai": return .ai
        case "engagement": return .engagement
        case "security": return .security
        default: return .system
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(type.color)
                            .shadow(color: type.color.opacity(0.35), radius: 6, y: 3)
                    )
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(noti.title ?? "Thông báo")
                        .font(.system(size: 15.5, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(noti.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    HStack {
                        Text(timestamp, style: .relative)
                            .font(.system(size: 12.5))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        if !isRead {
                            Circle()
                                .fill(type.color)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isRead ? Color.clear : type.color.opacity(0.6), lineWidth: 1.2)
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension Noti {
    var createdAt: Date {
        if let timestamp = meta["created_at"]?.value as? Double {
            return Date(timeIntervalSince1970: timestamp)
        }
        return Date()
    }

    var title: String {
        if let metaTitle = meta["title"]?.value as? String, !metaTitle.isEmpty {
            return metaTitle
        }
        return "Thông báo mới"
    }

    var message: String {
        if let metaMessage = meta["message"]?.value as? String {
            return metaMessage
        }
        return description
    }
}

enum NotiType: String {
    case transaction, budget, daily, goal, ai, engagement, security, system

    var icon: String {
        switch self {
        case .transaction: return "creditcard.fill"
        case .budget: return "dollarsign.circle.fill"
        case .daily: return "calendar"
        case .goal: return "target"
        case .ai: return "brain"
        case .engagement: return "flame.fill"
        case .security: return "lock.shield.fill"
        case .system: return "gearshape.fill"
        }
    }

    var color: Color {
        switch self {
        case .transaction: return Color(hex: "3B82F6")
        case .budget: return Color(hex: "FB923C")
        case .daily: return Color(hex: "8B5CF6")
        case .goal: return Color(hex: "10B981")
        case .ai: return Color(hex: "A78BFA")
        case .engagement: return Color(hex: "EF4444")
        case .security: return Color(hex: "F59E0B")
        case .system: return Color(hex: "6B7280")
        }
    }
}

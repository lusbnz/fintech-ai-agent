import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var auth: AuthViewModel
    @State private var displayName: String = ""
    @State private var isEditing = true
    @State private var isSaving = false
    
    private let avatarSize: CGFloat = 96
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    ZStack {
                        AsyncImage(url: URL(string: app.profile?.avatar ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                            case .failure:
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                            case .empty:
                                ProgressView()
                                    .scaleEffect(1.2)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: avatarSize, height: avatarSize)
                        .clipShape(Circle())
                    }
                    
                    Text(app.profile?.display_name ?? "Khách")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                    
                    Text(app.profile?.email ?? "No Email")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            
            Section("Tên hiển thị") {
                if isEditing {
                    TextField("Nhập tên", text: $displayName)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                } else {
                    HStack {
                        Text(displayName)
                            .foregroundStyle(.primary)
                    }
                }
            }
            
            Section("Tài khoản") {
                LabelRow(title: "Email", value: app.profile?.email ?? "No Email", icon: "envelope")
                LabelRow(title: "Gói", value: app.profile?.plan.capitalized ?? "Free", icon: "crown")
                LabelRow(title: "Thành viên từ", value: formattedDate(app.profile?.created_at), icon: "calendar")
            }
            .listRowBackground(Color(.secondarySystemBackground))
        }
        .navigationTitle("Thông tin cá nhân")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Lưu" : "Sửa") {
                    toggleEdit()
                }
                .fontWeight(.regular)
                .foregroundStyle(.blue)
                .disabled(isSaving)
            }
        }
        .onAppear {
            displayName = app.profile?.display_name ?? ""
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: isEditing)
        .hideKeyboardOnTap()
    }
    
    private func toggleEdit() {
        withAnimation(.easeInOut(duration: 0.25)) {
            if isEditing {
                saveName()
            } else {
                displayName = app.profile?.display_name ?? ""
                isEditing = true
            }
        }
    }
    
    private func saveName() {
        guard displayName != app.profile?.display_name else {
            isEditing = false
            return
        }
        
        isSaving = true
        Task {
            do {
                try await auth.updateProfile(displayName: displayName)
                await MainActor.run {
                    withAnimation(.easeInOut) {
                        isEditing = false
                        isSaving = false
                    }
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                }
            }
        }
    }
    
    private func formattedDate(_ dateString: String?) -> String {
        guard let dateString = dateString,
              let date = ISO8601DateFormatter().date(from: dateString) else {
            return "Unknown"
        }
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }
}

struct LabelRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 6)
    }
}

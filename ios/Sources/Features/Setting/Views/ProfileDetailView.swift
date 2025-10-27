import SwiftUI

struct ProfileDetailView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var displayName: String = ""
    @State private var isEditing = true
    @State private var isSaving = false
    
    private let avatarSize: CGFloat = 96
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    ZStack {
                        AsyncImage(url: URL(string: authViewModel.userProfile?.avatar ?? "")) { phase in
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
                    
                    Text(authViewModel.userProfile?.display_name ?? "Guest")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                    
                    Text(authViewModel.userProfile?.email ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            
            Section("Display Name") {
                if isEditing {
                    TextField("Enter name", text: $displayName)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                } else {
                    HStack {
                        Text(displayName)
                            .foregroundStyle(.primary)
                    }
                }
            }
            
            Section("Account") {
                LabelRow(title: "Email", value: authViewModel.userProfile?.email ?? "", icon: "envelope")
                LabelRow(title: "Plan", value: authViewModel.userProfile?.plan.capitalized ?? "Free", icon: "crown")
                LabelRow(title: "Member Since", value: formattedDate(authViewModel.userProfile?.created_at), icon: "calendar")
            }
            .listRowBackground(Color(.secondarySystemBackground))
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    toggleEdit()
                }
                .fontWeight(.regular)
                .foregroundStyle(.blue)
                .disabled(isSaving)
            }
        }
        .onAppear {
            displayName = authViewModel.userProfile?.display_name ?? ""
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: isEditing)
    }
    
    private func toggleEdit() {
        withAnimation(.easeInOut(duration: 0.25)) {
            if isEditing {
                saveName()
            } else {
                displayName = authViewModel.userProfile?.display_name ?? ""
                isEditing = true
            }
        }
    }
    
    private func saveName() {
        guard displayName != authViewModel.userProfile?.display_name else {
            isEditing = false
            return
        }
        
        isSaving = true
        Task {
            do {
                try await authViewModel.updateProfile(displayName: displayName)
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

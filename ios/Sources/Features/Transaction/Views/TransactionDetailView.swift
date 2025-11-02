import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    @Environment(\.dismiss) var dismiss
    @State private var showMenu = false
    @StateObject private var viewModel = TransactionViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
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
                        Button("Edit", systemImage: "pencil") {
                            viewModel.showEdit = true
                        }
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.showDeleteConfirm = true
                        }
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
                
                // MARK: - Title section
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.formattedDate)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                    Text(transaction.name)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                
                // MARK: - Timeline
                VStack(alignment: .leading, spacing: 24) {
                    if let location = transaction.location?.name, !location.isEmpty {
                        timelineRow(icon: "mappin.and.ellipse", title: location)
                    }
                    
                    timelineRow(icon: "tag", title: transaction.category ?? "Uncategorized")
                    
                    let formattedAmount = transaction.amount.formatVND()
                    timelineRow(
                        icon: transaction.type == "income" ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                        title: transaction.type == "income" ? "Thu nhập" : "Chi tiêu",
                        value: transaction.type == "income" ? "+\(formattedAmount)" : "-\(formattedAmount)",
                        isNoLine: transaction.image == nil
                    )
                    .foregroundColor(transaction.type == "income" ? .green : .red)
                    
                    if let image = transaction.image, !image.isEmpty {
                        imageSection(
                            icon: "photo.on.rectangle",
                            imageURL: image,
                            time: transaction.formattedDate
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.leading, 6)
                
                Spacer(minLength: 20)
            }
            .padding(.bottom, 32)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "EAF0FF"), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $viewModel.showEdit) {
            NavigationStack {
                CreateTransactionView(
                    transaction: transaction,
                    onSuccess: {
                        dismiss()
                    }
                )
            }
        }
        .alert("Delete Transaction", isPresented: $viewModel.showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    let success = await viewModel.deleteTransaction(transaction)
                    if success {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete \"\(transaction.name)\"?")
        }
    }
    
    // MARK: - UI components
    func timelineRow(icon: String, title: String, value: String? = nil, isNoLine: Bool? = false) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack {
                iconCircle(content: .icon(icon))
                if !(isNoLine ?? false) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .padding(.top, -4)
                        .padding(.bottom, -20)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                if let value = value {
                    Text(value)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    func imageSection(icon: String, imageURL: String, time: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack {
                iconCircle(content: .icon(icon))
//                Rectangle()
//                    .fill(Color.gray.opacity(0.3))
//                    .frame(width: 1)
//                    .frame(maxHeight: .infinity)
//                    .padding(.top, -4)
//                    .padding(.bottom, -20)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 260)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .shadow(color: .clear, radius: 0)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                Text(time)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(.trailing, 16)
    }
    
    enum IconContent {
        case icon(String)
        case text(String)
    }
    
    @ViewBuilder
    func iconCircle(content: IconContent) -> some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .overlay(Circle().stroke(Color.gray.opacity(0.25), lineWidth: 1))
                .frame(width: 28, height: 28)
            
            switch content {
            case .icon(let system):
                Image(systemName: system)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
            case .text(let text):
                Text(text)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
    }
}

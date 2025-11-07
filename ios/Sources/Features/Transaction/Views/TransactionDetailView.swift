import SwiftUI
import Charts

struct TransactionDetailView: View {
    let transaction: Transaction
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = TransactionViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "DDE9FF"), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    headerSection
                    summaryCard
                    infoSection
                    if let image = transaction.image, !image.isEmpty {
                        attachmentSection(imageURL: image)
                    }
                    Spacer(minLength: 40)
                }
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $viewModel.showEdit) {
            NavigationStack {
                CreateTransactionView(transaction: transaction) {
                    dismiss()
                }
            }
        }
        .alert("Delete Transaction", isPresented: $viewModel.showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    let success = await viewModel.deleteTransaction(transaction)
                    if success { dismiss() }
                }
            }
        } message: {
            Text("Are you sure you want to delete “\(transaction.name)”?")
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
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
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Summary Card (tên + số tiền)
    private var summaryCard: some View {
        VStack(spacing: 12) {
            Text(transaction.name)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(transaction.formattedDate)
                .font(.system(size: 13))
                .foregroundColor(.gray)

            Text(transaction.type == "income"
                 ? "+\(transaction.amount.formatVND())"
                 : "-\(transaction.amount.formatVND())")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    transaction.type == "income"
                    ? LinearGradient(colors: [.green], startPoint: .top, endPoint: .bottom)
                    : LinearGradient(colors: [.red], startPoint: .top, endPoint: .bottom)
                )
                .padding(.top, 6)
                .shadow(color: .black.opacity(0.1), radius: 1, y: 1)

            if let desc = transaction.description, !desc.isEmpty {
                Text("“\(desc)”")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.9))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        .padding(.horizontal)
        .transition(.scale)
    }

    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Transaction Details")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)

            VStack(spacing: 16) {
                detailRow(icon: "tag.fill", color: .blue, title: "Category", value: transaction.category)
                if let location = transaction.location?.name, !location.isEmpty {
                    detailRow(icon: "mappin.circle.fill", color: .teal, title: "Location", value: location)
                }
                detailRow(
                    icon: transaction.type == "income" ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                    color: transaction.type == "income" ? .green : .red,
                    title: transaction.type == "income" ? "Income" : "Expense",
                    value: transaction.type.capitalized
                )
                detailRow(icon: "calendar", color: .orange, title: "Date", value: transaction.formattedDate)
                detailRow(icon: "clock", color: .purple, title: "Created at", value: transaction.created_at.formattedDisplayDate())
            }
            .padding()
            .background(.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.06), radius: 5, y: 2)
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: viewModel.showEdit)
    }

    // MARK: - Attachment Section
    private func attachmentSection(imageURL: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "photo.fill.on.rectangle.fill")
                    .foregroundColor(.gray)
                Text("Attachment")
                    .font(.system(size: 16, weight: .semibold))
            }

            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.15))
                        ProgressView()
                    }
                    .frame(height: 220)
                case .success(let img):
                    img.resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                        .transition(.opacity.combined(with: .scale))
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
        }
        .padding()
        .background(.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 5, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Reusable Row
    private func detailRow(icon: String, color: Color, title: String, value: String?) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 17, weight: .medium))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
                Text(value ?? "—")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Helpers
extension String {
    func formattedDisplayDate() -> String {
        let df = ISO8601DateFormatter()
        if let date = df.date(from: self) {
            let output = DateFormatter()
            output.dateStyle = .medium
            output.timeStyle = .short
            return output.string(from: date)
        }
        return self
    }
}

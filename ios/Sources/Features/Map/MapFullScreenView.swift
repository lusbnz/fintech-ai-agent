import SwiftUI
import MapKit
import CoreLocation

// MARK: - Mock Data
extension Transaction {
    static func mockJourney(userId: String = "user123", budgetId: String = "budget456") -> [Transaction] {
        [
            Transaction(
                id: "1", name: "Cà phê Highlands", budget_id: budgetId, type: "outcome",
                description: "Cà phê sữa đá + bánh mì", user_id: userId, category: "Ăn uống",
                amount: 85000, date_time: "2025-11-08T08:30:00.000Z", image: nil,
                location: Location(name: "Highlands Phạm Ngọc Thạch", lat: 21.0178, lng: 105.8481),
                created_at: "2025-11-08T08:31:00.000Z", updated_at: "2025-11-08T08:31:00.000Z"
            ),
            Transaction(
                id: "2", name: "Đổ xăng Petrolimex", budget_id: budgetId, type: "outcome",
                description: "Full bình RON95", user_id: userId, category: "Di chuyển",
                amount: 350000, date_time: "2025-11-08T10:15:00.000Z", image: nil,
                location: Location(name: "Petrolimex Cầu Giấy", lat: 21.0182, lng: 105.8006),
                created_at: "2025-11-08T10:16:00.000Z", updated_at: "2025-11-08T10:16:00.000Z"
            ),
            Transaction(
                id: "3", name: "Ăn trưa Kichi-Kichi", budget_id: budgetId, type: "outcome",
                description: "Buffet lẩu Nhật", user_id: userId, category: "Ăn uống",
                amount: 289000, date_time: "2025-11-08T12:30:00.000Z", image: nil,
                location: Location(name: "Kichi-Kichi Royal City", lat: 21.0035, lng: 105.8142),
                created_at: "2025-11-08T12:31:00.000Z", updated_at: "2025-11-08T12:31:00.000Z"
            ),
            Transaction(
                id: "4", name: "Mua sắm VinMart", budget_id: budgetId, type: "outcome",
                description: "Mua thực phẩm tuần", user_id: userId, category: "Mua sắm",
                amount: 568000, date_time: "2025-11-08T16:20:00.000Z", image: nil,
                location: Location(name: "VinMart Times City", lat: 20.9969, lng: 105.8665),
                created_at: "2025-11-08T16:21:00.000Z", updated_at: "2025-11-08T16:21:00.000Z"
            ),
            Transaction(
                id: "5", name: "Phở Thìn", budget_id: budgetId, type: "outcome",
                description: "Phở bò tái + nước mía", user_id: userId, category: "Ăn uống",
                amount: 120000, date_time: "2025-11-08T20:45:00.000Z", image: nil,
                location: Location(name: "Phở Thìn Long Biên", lat: 21.0314, lng: 105.9035),
                created_at: "2025-11-08T20:46:00.000Z", updated_at: "2025-11-08T20:46:00.000Z"
            )
        ]
    }
}

// MARK: - Main Map Screen
struct MapFullScreenView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var camera = MapCameraPosition.automatic
    @State private var currentIndex = 0
    @State private var selectedTransaction: Transaction?
    @State private var selectedDate: Date? = nil
    @State private var showDatePicker = false
    @State private var isShowingDetail = false
    
    private let journey = Transaction.mockJourney()
    
    private var filteredJourney: [Transaction] {
        guard let selectedDate else { return journey }
        let calendar = Calendar.current
        return journey.filter {
            if let date = ISO8601DateFormatter().date(from: $0.date_time) {
                return calendar.isDate(date, inSameDayAs: selectedDate)
            }
            return false
        }
    }
    
    private var totalAmount: Double { filteredJourney.reduce(0) { $0 + $1.amount } }
    private var totalDistance: Double {
        guard filteredJourney.count > 1 else { return 0 }
        var distance = 0.0
        for i in 0..<filteredJourney.count - 1 {
            if let c1 = filteredJourney[i].location?.coordinate, let c2 = filteredJourney[i+1].location?.coordinate {
                distance += c1.distance(to: c2) / 1000
            }
        }
        return distance
    }
    
    var body: some View {
        ZStack {
            Map(position: $camera) {
                ForEach(filteredJourney.indices, id: \.self) { i in
                    let tx = filteredJourney[i]
                    if let coord = tx.location?.coordinate {
                        Annotation("", coordinate: coord) {
                            VStack(spacing: 2) {
                                ZStack {
                                    Circle()
                                        .fill(colorForAmount(tx.amount)) // 🔹 màu chính
                                        .frame(width: currentIndex == i ? 34 : 28, height: currentIndex == i ? 34 : 28)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2)) // 🔹 viền trắng
                                        .shadow(color: .black.opacity(currentIndex == i ? 0.25 : 0.1), radius: currentIndex == i ? 5 : 2, y: 2)
                                        .scaleEffect(currentIndex == i ? 1.2 : 1.0)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentIndex)
                                    
                                    Image(systemName: iconForCategory(tx.category))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .scaleEffect(currentIndex == i ? 1.15 : 1.0)
                                }
                                
                                // Số thứ tự nhỏ gọn hơn
                                Text("\(i + 1)")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundColor(.black.opacity(0.7))
                            }
                            .padding(4)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentIndex = i
                                    selectedTransaction = tx
                                    moveToTransaction(coord, lowered: true)
                                }
                            }
                        }
                        .annotationTitles(.hidden)
                    }
                }
            }
            .ignoresSafeArea()
            
            // Overlay
            VStack {
                // 🔹 Header gọn gàng, nền trắng
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.headline.bold())
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.white.opacity(0.9), in: Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
                            .shadow(color: .black.opacity(0.1), radius: 3)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("Hành trình chi tiêu")
                            .font(.headline.bold())
                            .foregroundColor(.black)
                        Text("\(filteredJourney.count) điểm • \(totalDistance, specifier: "%.1f") km • \(totalAmount, format: .currency(code: "VND"))")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.9), in: Capsule())
                    .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.1), radius: 3)
                    
                    Spacer()
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 🔹 Thanh điều hướng + lọc ngày
                VStack(spacing: 10) {
                    // Thanh điều hướng + lọc ngày
                    HStack(spacing: 24) {
                        glassButton(icon: "chevron.left",
                                    disabled: currentIndex == 0,
                                    action: prevStep)
                        
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { selectedDate ?? Date() },
                                set: { newDate in
                                    selectedDate = newDate
                                    currentIndex = 0 // reset hành trình sau khi chọn ngày mới
                                }
                            ),
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .frame(maxWidth: 180)
                        
                        glassButton(icon: "chevron.right",
                                    disabled: currentIndex >= filteredJourney.count - 1,
                                    action: nextStep)
                    }
                    
                    // Nút xóa lọc
                    if selectedDate != nil {
                        Button("Xóa lọc") {
                            withAnimation { selectedDate = nil }
                        }
                        .font(.footnote)
                        .foregroundColor(.blue)
                    }
                    
                    // 🔹 Thông tin sơ bộ của giao dịch hiện tại
                    if filteredJourney.indices.contains(currentIndex) {
                        let tx = filteredJourney[currentIndex]
                        Button {
                            selectedTransaction = tx // bấm mở sheet chi tiết
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: iconForCategory(tx.category))
                                    .font(.title2)
                                    .foregroundColor(colorForAmount(tx.amount))
                                    .frame(width: 32, height: 32)
                                    .background(Color.white, in: Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(tx.name)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                    Text(tx.location?.name ?? tx.category)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text("−\(tx.amount.formatted(.currency(code: "VND")))")
                                    .font(.subheadline.bold())
                                    .foregroundColor(colorForAmount(tx.amount))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
                            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 28))
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                .animation(.easeInOut(duration: 0.3), value: currentIndex)
            }
        }
        .sheet(item: $selectedTransaction) { tx in
            TransactionDetailSheet(transaction: tx)
                .presentationDetents([.fraction(0.45), .large])
                .presentationBackgroundInteraction(.enabled)
                .presentationCornerRadius(28)
        }
        .onAppear { centerOnJourney() }
    }
    
    // MARK: - Helper functions
    private func glassButton(icon: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(disabled ? .gray.opacity(0.4) : .black) // 🔹 icon đen
                .frame(width: 52, height: 52)
                .background(Color.white.opacity(0.9), in: Circle()) // 🔹 nền trắng
                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 0.4))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .disabled(disabled)
    }
    
    private func nextStep() {
        guard currentIndex < filteredJourney.count - 1 else { return }
        currentIndex += 1
        if let coord = filteredJourney[currentIndex].location?.coordinate {
            moveToTransaction(coord)
        }
    }

    private func prevStep() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        if let coord = filteredJourney[currentIndex].location?.coordinate {
            moveToTransaction(coord)
        }
    }
    
    private func moveToTransaction(_ coord: CLLocationCoordinate2D, lowered: Bool = false) {
        var center = coord
        if lowered { center.latitude -= 0.004 } // nhích xuống để pin ở nửa trên
        withAnimation(.easeInOut(duration: 2)) {
            camera = .region(MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
            ))
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    private func centerOnJourney() {
        guard let first = filteredJourney.first?.location?.coordinate,
              let last = filteredJourney.last?.location?.coordinate else { return }
        let center = CLLocationCoordinate2D(
            latitude: (first.latitude + last.latitude) / 2,
            longitude: (first.longitude + last.longitude) / 2
        )
        camera = .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
        ))
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Ăn uống": return "fork.knife"
        case "Di chuyển": return "car.fill"
        case "Mua sắm": return "bag.fill"
        default: return "creditcard"
        }
    }
    
    private func colorForAmount(_ amount: Double) -> Color {
        amount > 400000 ? .pink :
        amount > 200000 ? .orange : .green
    }
}

// MARK: - Distance Helper
extension CLLocationCoordinate2D {
    func distance(to: CLLocationCoordinate2D) -> Double {
        CLLocation(latitude: latitude, longitude: longitude)
            .distance(from: CLLocation(latitude: to.latitude, longitude: to.longitude))
    }
}


// MARK: - Detail Sheet
struct TransactionDetailSheet: View {
    let transaction: Transaction
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // 🔹 Header
                VStack(spacing: 10) {
                    Circle()
                        .fill(colorForCategory(transaction.category).gradient)
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: iconForCategory(transaction.category))
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .shadow(color: colorForCategory(transaction.category).opacity(0.25), radius: 8, y: 3)
                    
                    Text(transaction.name)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Text("−\(transaction.amount.formatted(.currency(code: "VND")))")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(colorForCategory(transaction.category))
                }
                .padding(.top, 12)
                
                // 🔹 Info section
                VStack(spacing: 16) {
                    infoRow(icon: "calendar", title: "Thời gian", value: formatDate(transaction.date_time))
                    infoRow(icon: "location", title: "Địa điểm", value: transaction.location?.name ?? "Không xác định")
                    infoRow(icon: "tag", title: "Danh mục", value: transaction.category)
                    if let note = transaction.description, !note.isEmpty {
                        infoRow(icon: "text.alignleft", title: "Ghi chú", value: note)
                    }
                }
                .padding(20)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                
                Spacer(minLength: 12)
            }
        }
        .presentationDetents([.fraction(0.45), .medium, .large])
        .presentationCornerRadius(28)
        .background(Color(.systemBackground))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Xong") { dismiss() }
                    .fontWeight(.semibold)
                    .tint(.blue)
            }
        }
    }
    
    // MARK: - Info Row
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 26)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(nil)
            }
            Spacer()
        }
    }
    
    // MARK: - Helpers
    private func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            let df = DateFormatter()
            df.dateFormat = "EEEE, d MMM yyyy • HH:mm"
            return df.string(from: date)
        }
        return iso
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Ăn uống": return .orange
        case "Di chuyển": return .blue
        case "Mua sắm": return .pink
        default: return .gray
        }
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Ăn uống": return "fork.knife.circle.fill"
        case "Di chuyển": return "car.circle.fill"
        case "Mua sắm": return "bag.circle.fill"
        default: return "creditcard.circle.fill"
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 36)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            Spacer()
        }
    }
}

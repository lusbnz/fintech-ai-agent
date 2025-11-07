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
    
    private let journey = Transaction.mockJourney()
    
    private var totalAmount: Double { journey.reduce(0) { $0 + $1.amount } }
    private var totalDistance: Double {
        guard journey.count > 1 else { return 0 }
        var distance = 0.0
        for i in 0..<journey.count - 1 {
            if let c1 = journey[i].location?.coordinate, let c2 = journey[i+1].location?.coordinate {
                distance += c1.distance(to: c2) / 1000
            }
        }
        return distance
    }
    
    var body: some View {
        ZStack {
            Map(position: $camera) {
                ForEach(journey.indices, id: \.self) { i in
                    let tx = journey[i]
                    if let coord = tx.location?.coordinate {
                        Annotation("", coordinate: coord) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: currentIndex == i ? 58 : 46)
                                    .overlay(Circle().stroke(.white.opacity(0.25), lineWidth: 1))
                                    .shadow(color: .black.opacity(0.3), radius: 10)
                                    .scaleEffect(currentIndex == i ? 1.25 : 1.0)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentIndex)
                                
                                VStack(spacing: 4) {
                                    Image(systemName: iconForCategory(tx.category))
                                        .font(.title2)
                                        .foregroundColor(colorForAmount(tx.amount))
                                    
                                    Text("\(i+1)")
                                        .font(.caption2.bold())
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(.black.opacity(0.5), in: Circle())
                                }
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    currentIndex = i
                                    selectedTransaction = tx
                                    moveToTransaction(coord)
                                }
                            }
                        }
                        .annotationTitles(.hidden)
                    }
                }
            }
            .ignoresSafeArea()
            
            // UI Overlay
            VStack {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                            .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 0.5))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("Hành trình chi tiêu")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                        Text("\(journey.count) điểm • \(totalDistance, specifier: "%.1f") km • \(totalAmount, format: .currency(code: "VND"))")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 0.5))
                    
                    Spacer()
                    Spacer().frame(width: 48)
                }
                .padding(.horizontal)
                .padding(.top, 30)
                
                Spacer()
                
                // Control bar
                HStack(spacing: 40) {
                    glassButton(icon: "chevron.left",
                                disabled: currentIndex == 0,
                                action: prevStep)
                    glassButton(icon: "chevron.right",
                                disabled: currentIndex >= journey.count - 1,
                                action: nextStep)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 35))
                .overlay(RoundedRectangle(cornerRadius: 35).stroke(.white.opacity(0.2), lineWidth: 0.6))
                .padding(.bottom, 40)
            }
        }
        .sheet(item: $selectedTransaction) { tx in
            TransactionDetailSheet(transaction: tx)
        }
        .onAppear { centerOnJourney() }
    }
    
    // MARK: - Helper functions
    private func glassButton(icon: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(disabled ? .gray.opacity(0.4) : .white)
                .frame(width: 70, height: 70)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.15), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.25), radius: 10, y: 5)
        }
        .disabled(disabled)
    }
    
    private func nextStep() {
        guard currentIndex < journey.count - 1 else { return }
        currentIndex += 1
        if let coord = journey[currentIndex].location?.coordinate {
            moveToTransaction(coord)
        }
    }
    
    private func prevStep() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        if let coord = journey[currentIndex].location?.coordinate {
            moveToTransaction(coord)
        }
    }
    
    private func moveToTransaction(_ coord: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 1.0)) {
            camera = .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
            ))
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    private func centerOnJourney() {
        guard let first = journey.first?.location?.coordinate,
              let last = journey.last?.location?.coordinate else { return }
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


// MARK: - Detail Sheet (unchanged but styled slightly)
struct TransactionDetailSheet: View {
    let transaction: Transaction
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                ZStack {
                    AngularGradient(colors: [.blue, .purple, .pink, .blue], center: .center)
                        .blur(radius: 60)
                        .frame(height: 240)
                        .mask(RoundedRectangle(cornerRadius: 28))
                    
                    VStack(spacing: 12) {
                        Image(systemName: iconForCategory(transaction.category))
                            .font(.system(size: 80))
                            .foregroundStyle(.white)
                            .symbolEffect(.bounce.down, options: .repeating)
                        
                        Text(transaction.name)
                            .font(.title.bold())
                            .foregroundStyle(.white)
                        
                        Text("−\(transaction.amount.formatted(.currency(code: "VND")))")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal)
                
                VStack(spacing: 20) {
                    DetailRow(icon: "calendar.circle.fill", title: "Thời gian", value: formatDate(transaction.date_time))
                    DetailRow(icon: "location.circle.fill", title: "Địa điểm", value: transaction.location?.name ?? "Không xác định")
                    DetailRow(icon: "tag.fill", title: "Danh mục", value: transaction.category)
                    DetailRow(icon: "note.text", title: "Ghi chú", value: transaction.description ?? "Không có")
                }
                .padding()
                .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
            }
            .padding(.top, 10)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Xong") { dismiss() }
                    .fontWeight(.semibold)
                    .tint(.blue)
            }
        }
    }
    
    private func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .short
            return df.string(from: date)
        }
        return iso
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

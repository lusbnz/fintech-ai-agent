import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: String = "Today"
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "E8F3E8"), .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 1)
                        }
                        
                        Spacer()
                        Text("Statistics")
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                        Color.clear.frame(width: 36) // balance spacing
                    }
                    
                    // MARK: Tab Selector
                    HStack(spacing: 12) {
                        ForEach(["Today", "Weekly", "Overall"], id: \.self) { tab in
                            Button {
                                selectedTab = tab
                            } label: {
                                Text(tab)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 16)
                                    .background(selectedTab == tab ? Color.gray.opacity(0.3) : Color.white)
                                    .cornerRadius(20)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                    
                    // MARK: Summary Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Summary")
                            .font(.system(size: 20, weight: .bold))
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            SummaryBox(title: "Current streak", value: "24")
                            SummaryBox(title: "Success rate", value: "94%")
                            SummaryBox(title: "Best streak day", value: "46")
                            SummaryBox(title: "Completed Challenge", value: "12")
                        }
                    }
                    
                    // MARK: Challenge List
                    VStack(alignment: .leading, spacing: 16) {
                        ChallengeProgressCard(
                            title: "Save a cup of tea",
                            subtitle: "23.000 VNĐ / Day",
                            weekProgress: [true, true, false, true, false, false, false]
                        )
                        
                        ChallengeProgressCard(
                            title: "Save for new car",
                            subtitle: "Progress: 23.000.000 / 80.000.000 VNĐ",
                            weekProgress: [true, true, true, true, false, false, false]
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
            
            // MARK: Floating Add Button
            Button {
                // Add new challenge
            } label: {
                ZStack {
                    LinearGradient(colors: [Color.blue, Color.purple],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                    .frame(width: 58, height: 58)
                    .clipShape(Circle())
                    .shadow(radius: 3)
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                }
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
        .navigationBarHidden(true)
    }
}

// MARK: Summary Box
struct SummaryBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 22, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// MARK: Challenge Progress Card
struct ChallengeProgressCard: View {
    let title: String
    let subtitle: String
    let weekProgress: [Bool] // 7 days
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                Spacer()
                Button {
                    // Save button
                } label: {
                    Text("Save")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .cornerRadius(20)
                }
            }
            
            // Week Progress
            HStack(spacing: 10) {
                ForEach(0..<7) { i in
                    VStack(spacing: 6) {
                        Text(["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][i])
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Image(systemName: weekProgress[i] ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(weekProgress[i] ? .green : .gray.opacity(0.4))
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    StatisticsView()
}

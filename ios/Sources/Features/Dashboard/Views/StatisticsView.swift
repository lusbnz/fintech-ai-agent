import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: String = "Today"
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "E8F3E8"),
                        Color(hex: "FFFFFF")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
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
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Summary")
                                .font(.system(size: 20, weight: .semibold))
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                SummaryBox(title: "Current streak", value: "24")
                                SummaryBox(title: "Success rate", value: "94%")
                                SummaryBox(title: "Best streak day", value: "46")
                                SummaryBox(title: "Completed Challenge", value: "12")
                            }
                        }
                        
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
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(10)
                    }
                }
            }
        }
    }
}

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

struct ChallengeProgressCard: View {
    let title: String
    let subtitle: String
    let weekProgress: [Bool]
    
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


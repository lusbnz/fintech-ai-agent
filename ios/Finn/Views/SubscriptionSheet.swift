import SwiftUI

struct SubscriptionSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan = "1_year"
    @State private var selectedTab = "Pro"
    @StateObject private var viewModel = PriceViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Image("intro1")
                            .frame(width: geo.size.width, height: geo.size.height * 0.45)
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "E1A974"),
                                    Color.white.opacity(0.5)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: geo.size.height * 0.55)
                            .overlay(
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .blur(radius: 20)
                                    .frame(height: geo.size.height * 0.55)
                            )
                        }
                    }
                    .ignoresSafeArea()
                }
                
                VStack(spacing: 20) {                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        HStack(spacing: 0) {
                            ForEach(["Pro", "Premium"], id: \.self) { tab in
                                Button(action: { selectedTab = tab }) {
                                    Text(tab)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            selectedTab == tab
                                            ? Color.white
                                            : Color(hex: "D0D0D0")
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 32))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(4)
                        .background(Color(hex: "D0D0D0"))
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                        
                        if viewModel.isLoading {
                            ProgressView("Đang tải...") .padding()
                        }
                        else if let data = viewModel.priceData {
                            TabView(selection: $selectedTab) {
                                VStack(spacing: 12) {
                                    ForEach(data.plan["Pro"] ?? []) { plan in
                                        planItem(
                                            title: plan.display,
                                            price: plan.price.formatVND()
                                        )
                                    }
                                }
                                .tag("Pro")
                                
                                VStack(spacing: 12) {
                                    ForEach(data.plan["Premium"] ?? []) { plan in
                                        planItem(
                                            title: plan.display,
                                            price: plan.price.formatVND()
                                        )
                                    }
                                }
                                .tag("Premium")
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .frame(height: 260)
                            .animation(.easeInOut, value: selectedTab)
                            .transition(.slide)
                        } else if let error = viewModel.error {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 4, y: 4)
                    .padding(.horizontal, 24)
                    .offset(y: 40)
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Text("Bao gồm?")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                        
                        HStack {
                            Text("Tính năng")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 100, alignment: .leading)
                            Spacer()
                            Text("Free")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            Spacer()
                            Text("Pro")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            Spacer()
                            Text("Premium")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        
                        Divider()
                        
                        rowFeature(name: "Prompt", values: ["100", "500", "Unlimited"])
                        rowFeature(name: "AI Advance", values: ["", "✓", "✓"])
                        
                        Spacer()
                        
                        Button(action: {}) {
                            VStack(spacing: 4) {
                                Text("Thanh toán")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Gói sẽ tự động gia hạn cho đến khi bạn hủy")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                    }
                }
            }
            .task {
                await viewModel.fetchPrices(version: "vi")
                if let data = viewModel.priceData,
                   let firstPlan = data.plan[selectedTab]?.first {
                    selectedPlan = firstPlan.display
                }
            }
        }
    }
    
    @ViewBuilder
    func planItem(title: String, price: String) -> some View {
        Button(action: { selectedPlan = title }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .bold()
                    Text(price)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(price)
                    .bold()
                if selectedPlan == title {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.orange)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selectedPlan == title ? Color.orange : Color.clear, lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "EEEEEE"))
                    )
            )
        }
        .foregroundColor(.black)
    }
    
    func rowFeature(name: String, values: [String]) -> some View {
        HStack {
            Text(name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)

            ForEach(values, id: \.self) { value in
                Text(value)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.vertical, 2)
    }
}

import SwiftUI

struct CreateBudgetView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var budgetName: String = ""
    @State private var amount: String = ""
    @State private var dateTime: Date = Date()
    @State private var period: String = "1 Month"
    @State private var showDescriptionInput = false
    
    let periods = ["Single", "1 Week", "1 Month", "1 Year"]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "F04A25"), Color(hex: "FFFFFF")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.5)
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Spacer(minLength: 12)
                    
                    Text("Create Budget")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "636363"))
                    
                    TextField("Budget Name", text: $budgetName)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: "636363"))
                        .padding(.vertical, 6)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(hex: "E0E0E0"))
                                .padding(.top, 40)
                        )
                        .padding(.horizontal)
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .padding()
                        .font(.system(size: 28, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(24)
                    
                    infoRow(icon: "calendar", title: "Datetime") {
                        DatePicker("", selection: $dateTime, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "636363"))
                            Text("Period")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "636363"))
                        }
                        
                        Text("Select how long this budget lasts")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "636363"))
                            .padding(.bottom, 8)
                        
                        Picker("Period", selection: $period) {
                            ForEach(periods, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(16)
                    
                    Spacer(minLength: 160)
                }
                .padding(.horizontal)
            }
            
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.7),
                        Color.white.opacity(0.8),
                        Color.white.opacity(0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
                .blur(radius: 12)
            }
            .ignoresSafeArea(edges: .bottom)
            
            VStack {
                Button(action: {
                    print("Budget Created: \(budgetName), \(amount), \(dateTime), \(period)")
                }) {
                    ZStack(alignment: .leading) {
                        Text("Create")
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(Color.black.opacity(0.75))
                            )
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background(Circle().fill(Color.black))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
    }
    
    private func infoRow<Content: View>(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "636363"))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "636363"))
                Spacer()
                content()
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
}

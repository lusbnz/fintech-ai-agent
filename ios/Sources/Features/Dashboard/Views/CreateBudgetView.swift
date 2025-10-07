import SwiftUI

struct CreateBudgetView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var amount: String = ""
    @State private var dateTime: Date = Date()
    @State private var period: String = "1 Month"
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "F5E6E8"), Color(hex: "F5E6E8")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Text("Create Budget")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "636363"))
                
                Text("Shopping")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "636363"))
                
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(24)
                    .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "636363"))
                        Text("Datetime")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "636363"))
                    }
                  
                    DatePicker("Select Date & Time", selection: $dateTime, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "scribble")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "636363"))
                        Text("Period")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "636363"))
                    }
                    
                    Text("What period you pay for this transaction?")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "636363"))
                        .padding(.bottom, 32)
                    
                    Picker("Period", selection: $period) {
                        Text("Single").tag("Single")
                        Text("1 Week").tag("1 Week")
                        Text("1 Month").tag("1 Month")
                        Text("1 Year").tag("1 Year")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(16)
                
                Button(action: {
                    print("Budget Created: \(amount), \(dateTime), \(period)")
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
                                    .fill(Color.black)
                                    .opacity(0.7)
                            )
                        
                        Button(action: {
                            print("Button tapped")
                        }) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(width: 42, height: 42)
                                .background(
                                    Circle()
                                        .fill(Color.black)
                                )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
            .padding(.horizontal)
        }
    }
}

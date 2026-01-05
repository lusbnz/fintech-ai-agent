import SwiftUI

struct BudgetItem: View {
    @EnvironmentObject var app: AppState
    
    let budget: Budget
    
    private var userCurrency: String {
        (app.profile?.currency ?? "VND").uppercased()
    }
    
    var color: Color {
        if budget.progress < 0.7 {
            return .mint
        } else if budget.progress < 0.9 {
            return .orange
        } else {
            return .red
        }
    }
    
    var recommendedDailyLimit: Double {
        guard let daysRemaining = budget.days_remaining,
              daysRemaining > 0 else {
            return 0
        }
        
        return budget.amount / daysRemaining
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Text(budget.name)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("\(Int(budget.progress * 100))%")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            BudgetProgressBar(progress: CGFloat(budget.progress), color: color)
                .frame(height: 8)
            
            HStack {
                Group {
                    Text("Còn lại: ").foregroundColor(.gray)
                    + Text("\(Int(budget.amount).formattedWithSeparator) \(userCurrency)")
                        .foregroundColor(.black)

                }
                .font(.system(size: 11))
                
                Spacer()
                
                Group {
                    Text("Hạn mức nên chi: ").foregroundColor(.gray)
                    + Text("\(Int(recommendedDailyLimit).formattedWithSeparator) \(userCurrency)")
                        .foregroundColor(.black)
                }
                .font(.system(size: 11))
            }
            
            HStack {
                Group {
                    Text("Tổng tiền vào: ").foregroundColor(.gray)
                    + Text("\(Int(budget.total_income).formattedWithSeparator) \(userCurrency)")
                        .foregroundColor(.black)
                }
                .font(.system(size: 11))
                
                Spacer()
                
                Group {
                    Text("Tổng tiền ra: ").foregroundColor(.gray)
                    + Text("\(Int(budget.total_outcome).formattedWithSeparator) \(userCurrency)")
                        .foregroundColor(.black)
                }
                .font(.system(size: 11))
            }
            
            if budget.recurring_active {
                HStack {
                    Group {
                        Text("Nạp tiền định kì").foregroundColor(.gray)
                    }
                    .font(.system(size: 11))
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
    }
}

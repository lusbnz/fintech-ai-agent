import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showCreateNew = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "F04A25"),
                    Color(hex: "FFFFFF")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.5)
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
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
                   Text("Your Budget")
                       .font(.system(size: 16, weight: .semibold))
                   Spacer()
                   Spacer().frame(width: 16)
               }
               .padding(.horizontal)
               .padding(.top, 8)
                
                Button(action: {
                    showCreateNew = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .frame(height: 44)
                        
                        HStack {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                            Text("Create New")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                VStack(spacing: 8) {
                    NavigationLink(
                        destination: BudgetDetailView(title: "Shopping", remain: "$600")
                    ) {
                        BudgetItem(title: "Shopping", remain: "$600")
                    }
                    NavigationLink(
                        destination: BudgetDetailView(title: "Dating", remain: "$230")
                    ) {
                        BudgetItem(title: "Dating", remain: "$230")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showCreateNew) {
            NavigationStack {
                CreateBudgetView()
            }
        }
    }
}

struct BudgetItem: View {
    let title: String
    let remain: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                Text("Remain: \(remain)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

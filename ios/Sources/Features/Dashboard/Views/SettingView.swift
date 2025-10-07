import SwiftUI

struct SettingView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showSubscriptionSheet = false
    
    var body: some View {
        Form {
            VStack(spacing: 8) {
                Text("Get Finny Premium")
                    .font(.headline)
                
                Text("Get an Advance AI that guides, insight and evolves with you, that push your wallet better.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    showSubscriptionSheet = true
                }) {
                    VStack(spacing: 4) {
                        Text("Subscribe")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Seven Days Free, Then $49.9 per Year")
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
            .padding(.vertical, 8)
            
            Section {
                NavigationLink("Quốc Việt") {
                    // Profile detail screen
                }
                
                HStack {
                    Text("Currency")
                    Spacer()
                    Text("VNĐ")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Language")
                    Spacer()
                    Text("Vietnamese")
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                HStack {
                    Text("Planning")
                    Spacer()
                    Text("Pro")
                        .foregroundColor(.secondary)
                }
                NavigationLink("Ask for Feature") {
                    // Feature request screen
                }
                NavigationLink("Review the App") {
                    // App Store Review
                }
            }
            
            Section {
                Button(role: .destructive) {
                    authViewModel.logout()
                } label: {
                    Text("Log out")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Setting")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            dismiss()
        }) {
            HStack(spacing: 2) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12))
            }
        })
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionSheet()
        }
    }
}

struct SubscriptionSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Choose Your Plan")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding()
            .navigationTitle("Subscription")
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
}

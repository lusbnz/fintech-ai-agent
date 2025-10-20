import SwiftUI

struct SettingView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showSubscriptionSheet = false
    
    @State private var selectedCurrency = "VNĐ"
    @State private var selectedLanguage = "Vietnamese"
    
    let currencies = ["VNĐ", "USD", "EUR"]
    let languages = ["Vietnamese", "English", "Japanese"]
    
    var body: some View {
        HStack {
           Button(action: { dismiss() }) {
               Image(systemName: "chevron.left")
                   .font(.system(size: 16, weight: .semibold))
                   .foregroundColor(.gray)
           }
           Spacer()
           Text("Setting")
               .font(.system(size: 16, weight: .semibold))
           Spacer()
           Spacer().frame(width: 16)
       }
       .padding(.horizontal)
       .padding(.top, 8)
        
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
                        Text("Subscription")
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
                
                Picker("Currency", selection: $selectedCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(languages, id: \.self) { language in
                        Text(language).tag(language)
                    }
                }
            }
            
            Section {
                Button {
                    showSubscriptionSheet = true
                } label: {
                    HStack {
                        Text("Planning")
                        Spacer()
                        Text("Pro")
                            .foregroundColor(.secondary)
                    }
                }
                
                NavigationLink("Export Data") {
                    // Feature request screen
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
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionSheet()
        }
    }
}

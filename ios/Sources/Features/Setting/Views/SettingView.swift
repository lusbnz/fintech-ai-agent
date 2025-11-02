import SwiftUI

struct SettingView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showSubscriptionSheet = false
    
    @State private var selectedCurrency: String = "VNĐ"
    @State private var selectedLanguage: String = "Vietnamese"
    
    private let currencyMap: [String: String] = [
        "usd": "USD", "vnd": "VNĐ"
    ]
    
    private let languageMap: [String: String] = [
        "en": "English", "vn": "Vietnamese"
    ]
    
    private let reverseCurrencyMap: [String: String] = [
        "USD": "usd", "VNĐ": "vnd"
    ]
    
    private let reverseLanguageMap: [String: String] = [
        "English": "en", "Vietnamese": "vn"
    ]
    
    var body: some View {
        VStack {
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
                    Text("Get Finny Premium").font(.headline)
                    Text("Get an Advance AI that guides, insight and evolves with you...")
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
                            Text("Plan auto-renews until canceled")
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
                    NavigationLink {
                        ProfileDetailView(authViewModel: authViewModel)
                    } label: {
                        Text(authViewModel.userProfile?.display_name ?? "Guest")
                    }
                    
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(Array(currencyMap.values), id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(Array(languageMap.values), id: \.self) { lang in
                            Text(lang).tag(lang)
                        }
                    }
                }
                
                Section {
                    Button("Planning") { showSubscriptionSheet = true }
                        .foregroundColor(.primary)
                    NavigationLink("Export Data") { EmptyView() }
                    NavigationLink("Ask for Feature") { EmptyView() }
                    NavigationLink("Review the App") { EmptyView() }
                }
                
                Section {
                    Button("Log out", role: .destructive) {
                        authViewModel.logout()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionSheet()
        }
        .onAppear {
            guard let profile = authViewModel.userProfile else { return }
            
            let uiCurrency = currencyMap[profile.currency ?? "vnd"] ?? "VNĐ"
            let uiLanguage = languageMap[profile.lang ?? "vn"] ?? "Vietnamese"
            
            if selectedCurrency != uiCurrency { selectedCurrency = uiCurrency }
            if selectedLanguage != uiLanguage { selectedLanguage = uiLanguage }
        }
        
        .onChange(of: selectedCurrency) { oldValue, newValue in
            guard oldValue != newValue else { return }
            Task {
                try? await authViewModel.updateProfile(currency: reverseCurrencyMap[newValue])
            }
        }
        .onChange(of: selectedLanguage) { oldValue, newValue in
            guard oldValue != newValue else { return }
            Task {
                try? await authViewModel.updateProfile(lang: reverseLanguageMap[newValue])
            }
        }
    }
}

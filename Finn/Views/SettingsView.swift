import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var exportVM = ExportViewModel()
    @State private var showShareSheet = false
    
    @State private var showSubscriptionSheet = false
    
    @State private var selectedCurrency: String = "VND"
    @State private var selectedLanguage: String = "Vietnamese"
    
    @State private var showFeatureModal = false
    @State private var featureText: String = ""
    
    private let currencyMap: [String: String] = [
        "vnd": "VND"
    ]
    
    private let reverseCurrencyMap: [String: String] = [
        "VND": "vnd"
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Text("Cài đặt")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Form {
                    Section {
                        NavigationLink {
                            ProfileView()
                        } label: {
                            Text(app.profile?.display_name ?? "Khách")
                        }
                        
                        Picker("Tiền tệ", selection: $selectedCurrency) {
                            ForEach(Array(currencyMap.values), id: \.self) { currency in
                                Text(currency).tag(currency)
                            }
                        }
                        NavigationLink("Danh mục") {
                            CategoryView()
                        }
                    }
                    
                    Section {
                        Button("Xuất dữ liệu") {
                            Task {
                                await exportVM.exportStatement()
                                
                                if exportVM.downloadedPDFURL != nil {
                                    showShareSheet = true
                                }
                            }
                        }
                        Button("Đề xuất tính năng") {
                            showFeatureModal = true
                        }
                        Button("Đánh giá App") {
                            if let url = URL(string: "https://apps.apple.com/app/") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    
                    Section {
                        Button("Đăng xuất", role: .destructive) {
                            auth.logout()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showSubscriptionSheet) {
                SubscriptionSheet()
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportVM.downloadedPDFURL {
                    ShareSheet(items: [url])
                }
            }
            .onAppear {
                guard let profile = app.profile else { return }
                selectedCurrency = currencyMap[profile.currency ?? "vnd"] ?? "VNĐ"
            }
            .onChange(of: selectedCurrency) { oldValue, newValue in
                guard oldValue != newValue else { return }
                Task {
                    try? await auth.updateProfile(currency: reverseCurrencyMap[newValue])
                }
            }
            .sheet(isPresented: $showFeatureModal) {
                FeatureRequestSheet(
                    text: $featureText,
                    onClose: {
                        showFeatureModal = false
                    }
                )
            }
        }
    }
}

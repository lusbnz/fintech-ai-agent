import SwiftUI

struct SettingView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        Form {
            Section {
                VStack(spacing: 8) {
                    Text("Get Finny Premium")
                        .font(.headline)
                    
                    Text("Get an Advance AI that guides, insight and evolves with you, that push your wallet better.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        // Action Subscribe
                    }) {
                        VStack {
                            Text("Subscribe")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            
                            Text("Seven Day’s free then $79.9 per Year")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
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
    }
}

struct SubscriptionSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Choose Your Plan")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Upgrade to Finny Premium to unlock all features and get deeper financial insights.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Subscription")
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
}

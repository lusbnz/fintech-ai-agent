struct BudgetDetailView: View {
    let title: String
    let remain: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text("Remaining: \(remain)")
                .font(.headline)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
    }
}

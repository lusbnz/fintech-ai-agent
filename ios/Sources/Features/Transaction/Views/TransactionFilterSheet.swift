import SwiftUI

struct TransactionFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var selectedBudgetId: String?
    
    let budgets: [Budget]
    let onApply: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Date Range") {
                    DatePicker(
                        "From",
                        selection: Binding(
                            get: { startDate ?? Date() },
                            set: { startDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    
                    DatePicker(
                        "To",
                        selection: Binding(
                            get: { endDate ?? Date() },
                            set: { endDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                }
                
                Section("Budget") {
                    Picker("Budget", selection: Binding(
                        get: { selectedBudgetId ?? "" },
                        set: { selectedBudgetId = $0.isEmpty ? nil : $0 }
                    )) {
                        Text("All Budgets").tag(String?.none)
                        ForEach(budgets) { budget in
                            Text(budget.name).tag(Optional(budget.id))
                        }
                    }
                }
            }
            .navigationTitle("Filter Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

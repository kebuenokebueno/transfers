//
//  AddTransferView.swift
//  Transfers
//

import SwiftUI

struct AddTransferView: View {
    @Environment(Router.self) private var router
    @Environment(TransferWorker.self) private var transferWorker

    @State private var viewModel: AddTransferViewModel?
    @State private var amount = ""
    @State private var description = ""
    @State private var category = "Food"
    @State private var isIncome = false

    let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Type", selection: $isIncome) {
                        Text("Expense").tag(false)
                        Text("Income").tag(true)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Details") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    TextField("Description", text: $description)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                }
            }
            .navigationTitle("Add Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel?.dismiss() }
                        .disabled(viewModel?.isSaving ?? false)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let value = Double(amount) else { return }
                        viewModel?.saveTransfer(
                            amount: value,
                            description: description,
                            category: category,
                            isIncome: isIncome
                        )
                    }
                    .disabled(amount.isEmpty || description.isEmpty || (viewModel?.isSaving ?? false))
                }
            }
            .disabled(viewModel?.isSaving ?? false)
            .overlay { if viewModel?.isSaving ?? false { ProgressView("Saving...") } }
            .alert("Error", isPresented: .constant(viewModel?.errorMessage != nil)) {
                Button("OK") { viewModel?.errorMessage = nil }
            } message: {
                Text(viewModel?.errorMessage ?? "")
            }
        }
        .task { setup() }
    }

    private func setup() {
        guard viewModel == nil else { return }
        viewModel = AddTransferViewModel(transferWorker: transferWorker, router: router)
    }
}

#Preview {
    AddTransferView()
        .environment(Router())
        .environment(TransferWorker(swiftDataService: SwiftDataService(), supabaseService: SupabaseService()))

}

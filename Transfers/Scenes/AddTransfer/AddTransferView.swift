//
//  AddTransferView.swift
//  Transfers
//

import SwiftUI

struct AddTransferView: View {
    @Environment(Router.self) private var router
    @Environment(TransferWorker.self) private var transferWorker

    @State private var viewController = AddTransferViewController()
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
                    Button("Cancel") { router.dismiss() }
                        .disabled(viewController.isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let value = Double(amount) else { return }
                        viewController.saveTransfer(
                            amount: value,
                            description: description,
                            category: category,
                            isIncome: isIncome
                        )
                    }
                    .disabled(amount.isEmpty || description.isEmpty || viewController.isSaving)
                }
            }
            .disabled(viewController.isSaving)
            .overlay { if viewController.isSaving { ProgressView("Saving...") } }
            .alert("Error", isPresented: .constant(viewController.errorMessage != nil)) {
                Button("OK") { viewController.errorMessage = nil }
            } message: {
                Text(viewController.errorMessage ?? "")
            }
        }
        .task { setup() }
    }

    private func setup() {
        guard viewController.interactor == nil else { return }

        let interactor = AddTransferInteractor(transferWorker: transferWorker)
        let presenter  = AddTransferPresenter()
        let noteRouter = AddTransferRouter(router: router)

        viewController.interactor = interactor
        viewController.router = noteRouter
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
}

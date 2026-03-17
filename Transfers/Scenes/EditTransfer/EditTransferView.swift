//
//  EditTransferView.swift
//  Transfers
//

import SwiftUI

struct EditTransferView: View {
    @Environment(Router.self) private var router
    @Environment(TransferWorker.self) private var transferWorker
    @Environment(SwiftDataService.self) private var swiftDataService

    let transferId: String

    @State private var viewController = EditTransferViewController()

    let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]

    var body: some View {
        Form {
            if viewController.isLoading {
                ProgressView("Loading...")
            } else {
                Section("Details") {
                    TextField("Amount", text: $viewController.amount)
                        .keyboardType(.decimalPad)
                    TextField("Description", text: $viewController.description)
                    Picker("Category", selection: $viewController.category) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                }
            }
        }
        .navigationTitle("Edit Transfer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewController.saveTransfer(transferId: transferId)
                }
                .disabled(
                    viewController.amount.isEmpty ||
                    viewController.description.isEmpty ||
                    viewController.isSaving
                )
            }
        }
        .disabled(viewController.isSaving)
        .overlay { if viewController.isSaving { ProgressView("Saving...") } }
        .alert("Error", isPresented: .constant(viewController.errorMessage != nil)) {
            Button("OK") { viewController.errorMessage = nil }
        } message: {
            Text(viewController.errorMessage ?? "")
        }
        .task { setup() }
    }

    private func setup() {
        guard viewController.interactor == nil else { return }

        let interactor = EditTransferInteractor(
            transferWorker: transferWorker,
            swiftDataService: swiftDataService
        )
        let presenter  = EditTransferPresenter()
        let transferRouter = EditTransferRouter(router: router)

        viewController.interactor = interactor
        viewController.router = transferRouter
        interactor.presenter = presenter
        presenter.viewController = viewController

        viewController.loadTransfer(transferId: transferId)
    }
}

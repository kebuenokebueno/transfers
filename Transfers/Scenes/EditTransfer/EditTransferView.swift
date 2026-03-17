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

    @State private var viewModel: EditTransferViewModel?

    let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]

    var body: some View {
        Form {
            if let viewModel, !viewModel.isLoading {
                Section("Details") {
                    TextField("Amount", text: Binding(
                        get: { viewModel.amount },
                        set: { viewModel.amount = $0 }
                    ))
                    .keyboardType(.decimalPad)
                    
                    TextField("Description", text: Binding(
                        get: { viewModel.description },
                        set: { viewModel.description = $0 }
                    ))
                    
                    Picker("Category", selection: Binding(
                        get: { viewModel.category },
                        set: { viewModel.category = $0 }
                    )) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationTitle("Edit Transfer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel?.saveTransfer(transferId: transferId)
                }
                .disabled(
                    (viewModel?.amount.isEmpty ?? true) ||
                    (viewModel?.description.isEmpty ?? true) ||
                    (viewModel?.isSaving ?? false)
                )
            }
        }
        .disabled(viewModel?.isSaving ?? false)
        .overlay { if viewModel?.isSaving ?? false { ProgressView("Saving...") } }
        .alert("Error", isPresented: .constant(viewModel?.errorMessage != nil)) {
            Button("OK") { viewModel?.errorMessage = nil }
        } message: {
            Text(viewModel?.errorMessage ?? "")
        }
        .task { setup() }
    }

    private func setup() {
        guard viewModel == nil else { return }
        
        viewModel = EditTransferViewModel(
            transferWorker: transferWorker,
            swiftDataService: swiftDataService,
            router: router
        )
        viewModel?.loadTransfer(transferId: transferId)
    }
}

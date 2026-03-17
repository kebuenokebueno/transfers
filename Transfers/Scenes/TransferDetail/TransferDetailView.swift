//
//  TransferDetailView.swift
//  Transfers
//

import SwiftUI

struct TransferDetailView: View {
    @Environment(Router.self) private var router
    @Environment(TransferWorker.self) private var transferWorker
    @Environment(SwiftDataService.self) private var swiftDataService

    let transferId: String

    @State private var viewController = TransferDetailViewController()
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            if let transfer = viewController.transfer {
                VStack(spacing: 24) {
                    Text(transfer.amount)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(transfer.isPositive ? .green : .primary)

                    Text(transfer.category)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(20)

                    Divider()

                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(label: "Description", value: transfer.description)
                        DetailRow(label: "Date",        value: transfer.date)
                        DetailRow(label: "Sync Status", value: transfer.syncStatus)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    Spacer()

                    Button {
                        viewController.didTapEdit(transferId: transfer.id)
                    } label: {
                        Label("Edit Transfer", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Transfer", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                ContentUnavailableView(
                    "Transfer Not Found",
                    systemImage: "transfer.text",
                    description: Text("This transfer may have been deleted")
                )
            }
        }
        .navigationTitle("Transfer Details")
        .navigationBarTitleDisplayMode(.inline)
        // Reload when navigating back from EditTransfer
        .task(id: router.path.count) {
            guard viewController.interactor != nil else { return }
            viewController.loadTransfer(transferId: transferId)
        }
        .confirmationDialog("Delete Transfer", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewController.deleteTransfer(transferId: transferId)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure? This cannot be undone.")
        }
        .alert("Error", isPresented: .constant(viewController.errorMessage != nil)) {
            Button("OK") { viewController.errorMessage = nil }
        } message: {
            Text(viewController.errorMessage ?? "")
        }
        .task { setup() }
    }

    private func setup() {
        guard viewController.interactor == nil else { return }

        let interactor = TransferDetailInteractor(
            transferWorker: transferWorker,
            swiftDataService: swiftDataService
        )
        let presenter  = TransferDetailPresenter()
        let noteRouter = TransferDetailRouter(router: router)

        viewController.interactor    = interactor
        viewController.router        = noteRouter
        interactor.presenter         = presenter
        presenter.viewController     = viewController

        viewController.loadTransfer(transferId: transferId)
    }
}

// MARK: - Supporting Views

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

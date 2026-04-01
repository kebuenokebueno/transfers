//
//  TransferListView.swift
//  Transfers
//

import SwiftUI
import SwiftData

struct TransferListView: View {
    @Environment(Router.self) private var router
    @Environment(TransferWorker.self) private var transferWorker
    @Environment(SwiftDataService.self) private var swiftDataService

    @State private var viewModel: TransferListViewModel?

    var body: some View {
        Group {
            if let viewModel {
                TransferListContent(
                    transfers: viewModel.displayedTransfers,
                    isLoading: viewModel.isLoading,
                    lastError: viewModel.errorMessage,
                    onTapTransfer: { transfer in
                        viewModel.didSelectTransfer(transferId: transfer.id)
                    },
                    onDeleteTransfer: { transfer in
                        viewModel.deleteTransfer(transferId: transfer.id)
                    },
                    onAddTransfer: {
                        viewModel.didTapAddTransfer()
                    },
                    onFetch: {
                        viewModel.loadTransfers()
                    },
                    onClearError: {
                        viewModel.errorMessage = nil
                    }
                )
                // Reload when AddTransfer sheet is dismissed
                .task(id: router.presentedSheet == nil) {
                    viewModel.loadTransfers()
                }
                // Reload when navigating back from EditTransfer or TransferDetail
                .task(id: router.path.count) {
                    viewModel.loadTransfers()
                }
            } else {
                ProgressView()
                    .task { setup() }
            }
        }
    }

    // MARK: - Setup

    private func setup() {
        guard viewModel == nil else { return }
        
        viewModel = TransferListViewModel(
            transferWorker: transferWorker,
            swiftDataService: swiftDataService,
            router: router
        )
        viewModel?.loadTransfers()
    }
}

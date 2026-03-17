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

    @State private var viewController = TransferListViewController()

    var body: some View {
        TransferListContent(
            transfers: viewController.displayedNotes,
            isLoading: viewController.isLoading,
            lastError: viewController.errorMessage,
            onTapNote: { transfer in
                viewController.didSelectNote(transferId: transfer.id)
            },
            onDeleteTransfer: { transfer in
                viewController.deleteTransfer(transferId: transfer.id)
            },
            onAddTransfer: {
                viewController.didTapAddTransfer()
            },
            onFetch: {
                viewController.loadTransfers()
            },
            onClearError: {
                viewController.errorMessage = nil
            }
        )
        // Reload when AddTransfer sheet is dismissed
        .task(id: router.presentedSheet == nil) {
            guard viewController.interactor != nil else { return }
            viewController.loadTransfers()
        }
        // Reload when navigating back from EditTransfer or TransferDetail
        .task(id: router.path.count) {
            guard viewController.interactor != nil else { return }
            viewController.loadTransfers()
        }
        .task { setup() }
    }

    // MARK: - VIP Assembly

    private func setup() {
        guard viewController.interactor == nil else { return }

        let interactor = TransferListInteractor(
            transferWorker: transferWorker,
            swiftDataService: swiftDataService
        )
        let presenter  = TransferListPresenter()
        let noteRouter = TransferListRouter(router: router)

        viewController.interactor    = interactor
        viewController.router        = noteRouter
        interactor.presenter         = presenter
        presenter.viewController     = viewController

        viewController.loadTransfers()
    }
}

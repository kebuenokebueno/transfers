//
//  TransferDetailViewController.swift
//  Transfers
//

import Foundation

protocol TransferDetailDisplayLogic: AnyObject {
    func displayTransfer(viewModel: TransferDetailScene.FetchTransfer.ViewModel)
    func displayDeleteResult(viewModel: TransferDetailScene.DeleteTransfer.ViewModel)
}

@MainActor
@Observable
class TransferDetailViewController: TransferDetailDisplayLogic {
    var interactor: TransferDetailBusinessLogic?
    var router: TransferDetailRoutingLogic?

    // View State
    var transfer: TransferViewModel?
    var shouldDismiss = false
    var errorMessage: String?

    // MARK: - Display (called by Presenter)

    func displayTransfer(viewModel: TransferDetailScene.FetchTransfer.ViewModel) {
        transfer = viewModel.transfer
    }

    func displayDeleteResult(viewModel: TransferDetailScene.DeleteTransfer.ViewModel) {
        if viewModel.success {
            router?.dismiss()
        } else {
            errorMessage = viewModel.message
        }
    }

    // MARK: - User Actions → Interactor

    func loadTransfer(transferId: String) {
        Task { await interactor?.fetchTransfer(request: .init(transferId: transferId)) }
    }

    func deleteTransfer(transferId: String) {
        Task { await interactor?.deleteTransfer(request: .init(transferId: transferId)) }
    }

    // MARK: - User Actions → Router

    func didTapEdit(transferId: String) {
        router?.routeToEditTransfer(transferId: transferId)
    }
}

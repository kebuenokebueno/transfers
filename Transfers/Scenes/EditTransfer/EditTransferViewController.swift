//
//  EditTransferViewController.swift
//  Transfers
//

import Foundation

protocol EditTransferRoutingLogic {
    func dismiss()
}

@MainActor
@Observable
class EditTransferViewController: EditTransferDisplayLogic {
    var interactor: EditTransferBusinessLogic?
    var router: EditTransferRoutingLogic?

    // View State (pre-filled from Presenter)
    var amount = ""
    var description = ""
    var category = ""
    var isPositive = true
    var isSaving = false
    var isLoading = true
    var errorMessage: String?

    // MARK: - Display (called by Presenter)

    func displayTransfer(viewModel: EditTransferScene.LoadTransfer.ViewModel) {
        amount      = viewModel.amount
        description = viewModel.description
        category    = viewModel.category
        isPositive  = viewModel.transfer?.isPositive ?? true
        isLoading   = false
    }

    func displaySaveResult(viewModel: EditTransferScene.SaveTransfer.ViewModel) {
        isSaving = false
        if viewModel.success {
            router?.dismiss()
        } else {
            errorMessage = viewModel.message
        }
    }

    // MARK: - User Actions → Interactor

    func loadTransfer(transferId: String) {
        Task { await interactor?.loadTransfer(request: .init(transferId: transferId)) }
    }

    func saveTransfer(transferId: String) {
        guard let value = Double(amount) else { return }
        isSaving = true
        Task {
            await interactor?.saveTransfer(request: .init(
                transferId: transferId,
                amount: value,
                description: description,
                category: category,
                isPositive: isPositive
            ))
        }
    }
}

// MARK: - Router

@MainActor
class EditTransferRouter: EditTransferRoutingLogic {
    private let router: Router

    init(router: Router) {
        self.router = router
    }

    func dismiss() {
        router.navigateBack()
    }
}

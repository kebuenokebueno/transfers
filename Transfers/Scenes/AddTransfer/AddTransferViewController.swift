//
//  AddTransferViewController.swift
//  Transfers
//

import Foundation

protocol AddTransferDisplayLogic: AnyObject {
    func displaySaveResult(viewModel: AddTransferScene.SaveTransfer.ViewModel)
}

protocol AddTransferRoutingLogic {
    func dismiss()
}

@MainActor
@Observable
class AddTransferViewController: AddTransferDisplayLogic {
    var interactor: AddTransferBusinessLogic?
    var router: AddTransferRoutingLogic?

    // View State
    var isSaving = false
    var errorMessage: String?

    // MARK: - Display (called by Presenter)

    func displaySaveResult(viewModel: AddTransferScene.SaveTransfer.ViewModel) {
        isSaving = false
        if viewModel.success {
            router?.dismiss()
        } else {
            errorMessage = viewModel.message
        }
    }

    // MARK: - User Actions → Interactor

    func saveTransfer(amount: Double, description: String, category: String, isIncome: Bool) {
        isSaving = true
        Task {
            await interactor?.saveTransfer(request: .init(
                amount: amount,
                description: description,
                category: category,
                isIncome: isIncome
            ))
        }
    }
}

// MARK: - Router

@MainActor
class AddTransferRouter: AddTransferRoutingLogic {
    private let router: Router

    init(router: Router) {
        self.router = router
    }

    func dismiss() {
        router.dismiss()
    }
}

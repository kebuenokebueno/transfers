//
//  AddTransferPresenter.swift
//  Transfers
//

import Foundation

protocol AddTransferPresentationLogic {
    func presentSaveResult(response: AddTransferScene.SaveNote.Response)
}

@MainActor
class AddTransferPresenter: AddTransferPresentationLogic {
    weak var viewController: AddTransferDisplayLogic?

    func presentSaveResult(response: AddTransferScene.SaveNote.Response) {
        let vm = AddTransferScene.SaveNote.ViewModel(
            success: response.success,
            message: response.success ? "Transfer created successfully" : "Failed to create transfer"
        )
        viewController?.displaySaveResult(viewModel: vm)
    }
}

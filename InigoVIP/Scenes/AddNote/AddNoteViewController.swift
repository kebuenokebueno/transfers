//
//  AddNoteViewController.swift
//  InigoVIP
//

import Foundation

protocol AddNoteDisplayLogic: AnyObject {
    func displaySaveResult(viewModel: AddNoteScene.SaveNote.ViewModel)
}

protocol AddNoteRoutingLogic {
    func dismiss()
}

@MainActor
@Observable
class AddNoteViewController: AddNoteDisplayLogic {
    var interactor: AddNoteBusinessLogic?
    var router: AddNoteRoutingLogic?

    // View State
    var isSaving = false
    var errorMessage: String?

    // MARK: - Display (called by Presenter)

    func displaySaveResult(viewModel: AddNoteScene.SaveNote.ViewModel) {
        isSaving = false
        if viewModel.success {
            router?.dismiss()
        } else {
            errorMessage = viewModel.message
        }
    }

    // MARK: - User Actions → Interactor

    func saveNote(amount: Double, description: String, category: String, isIncome: Bool) {
        isSaving = true
        Task {
            await interactor?.saveNote(request: .init(
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
class AddNoteRouter: AddNoteRoutingLogic {
    private let router: Router

    init(router: Router) {
        self.router = router
    }

    func dismiss() {
        router.dismiss()
    }
}

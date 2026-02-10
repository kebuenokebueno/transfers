//
//  EditNoteViewController.swift
//  InigoVIP
//

import Foundation

protocol EditNoteRoutingLogic {
    func dismiss()
}

@MainActor
@Observable
class EditNoteViewController: EditNoteDisplayLogic {
    var interactor: EditNoteBusinessLogic?
    var router: EditNoteRoutingLogic?

    // View State (pre-filled from Presenter)
    var amount = ""
    var description = ""
    var category = ""
    var isPositive = true
    var isSaving = false
    var isLoading = true
    var errorMessage: String?

    // MARK: - Display (called by Presenter)

    func displayNote(viewModel: EditNoteScene.LoadNote.ViewModel) {
        amount      = viewModel.amount
        description = viewModel.description
        category    = viewModel.category
        isPositive  = viewModel.note?.isPositive ?? true
        isLoading   = false
    }

    func displaySaveResult(viewModel: EditNoteScene.SaveNote.ViewModel) {
        isSaving = false
        if viewModel.success {
            router?.dismiss()
        } else {
            errorMessage = viewModel.message
        }
    }

    // MARK: - User Actions → Interactor

    func loadNote(noteId: String) {
        Task { await interactor?.loadNote(request: .init(noteId: noteId)) }
    }

    func saveNote(noteId: String) {
        guard let value = Double(amount) else { return }
        isSaving = true
        Task {
            await interactor?.saveNote(request: .init(
                noteId: noteId,
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
class EditNoteRouter: EditNoteRoutingLogic {
    private let router: Router

    init(router: Router) {
        self.router = router
    }

    func dismiss() {
        router.navigateBack()
    }
}

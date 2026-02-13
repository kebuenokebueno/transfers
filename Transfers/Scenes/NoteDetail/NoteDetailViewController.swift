//
//  NoteDetailViewController.swift
//  Transfers
//

import Foundation

protocol NoteDetailDisplayLogic: AnyObject {
    func displayNote(viewModel: NoteDetailScene.FetchNote.ViewModel)
    func displayDeleteResult(viewModel: NoteDetailScene.DeleteNote.ViewModel)
}

@MainActor
@Observable
class NoteDetailViewController: NoteDetailDisplayLogic {
    var interactor: NoteDetailBusinessLogic?
    var router: NoteDetailRoutingLogic?

    // View State
    var note: NoteViewModel?
    var shouldDismiss = false
    var errorMessage: String?

    // MARK: - Display (called by Presenter)

    func displayNote(viewModel: NoteDetailScene.FetchNote.ViewModel) {
        note = viewModel.note
    }

    func displayDeleteResult(viewModel: NoteDetailScene.DeleteNote.ViewModel) {
        if viewModel.success {
            router?.dismiss()
        } else {
            errorMessage = viewModel.message
        }
    }

    // MARK: - User Actions → Interactor

    func loadNote(noteId: String) {
        Task { await interactor?.fetchNote(request: .init(noteId: noteId)) }
    }

    func deleteNote(noteId: String) {
        Task { await interactor?.deleteNote(request: .init(noteId: noteId)) }
    }

    // MARK: - User Actions → Router

    func didTapEdit(noteId: String) {
        router?.routeToEditNote(noteId: noteId)
    }
}

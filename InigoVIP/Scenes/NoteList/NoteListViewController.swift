//
//  NoteListViewController.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation
internal import Combine


protocol NoteDisplayLogic: AnyObject {
    func displayNotes(viewModel: NoteScene.FetchNotes.ViewModel)
    func displayCreateResult(viewModel: NoteScene.CreateNote.ViewModel)
    func displayUpdateResult(viewModel: NoteScene.UpdateNote.ViewModel)
    func displayDeleteResult(viewModel: NoteScene.DeleteNote.ViewModel)
    func displayNote(viewModel: NoteScene.FetchNote.ViewModel)
}


@MainActor
@Observable
class NoteListViewController: NoteDisplayLogic {
    var interactor: NoteListInteractor?
    
    // View State
    var displayedNotes: [NoteScene.FetchNotes.ViewModel.DisplayedNote] = []
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?
    
    // MARK: - Display Methods
    
    func displayNotes(viewModel: NoteScene.FetchNotes.ViewModel) {
        displayedNotes = viewModel.displayedNotes
        isLoading = false
    }
    
    func displayCreateResult(viewModel: NoteScene.CreateNote.ViewModel) {
        if viewModel.success {
            successMessage = viewModel.message
            // Refresh list
            Task {
                await interactor?.fetchNotes(request: NoteScene.FetchNotes.Request())
            }
        } else {
            errorMessage = viewModel.message
        }
    }
    
    func displayUpdateResult(viewModel: NoteScene.UpdateNote.ViewModel) {
        if viewModel.success {
            successMessage = viewModel.message
            // Refresh list
            Task {
                await interactor?.fetchNotes(request: NoteScene.FetchNotes.Request())
            }
        } else {
            errorMessage = viewModel.message
        }
    }
    
    func displayDeleteResult(viewModel: NoteScene.DeleteNote.ViewModel) {
        if viewModel.success {
            successMessage = viewModel.message
        } else {
            errorMessage = viewModel.message
        }
    }
    
    func displayNote(viewModel: NoteScene.FetchNote.ViewModel) {
        // Handle single note display
    }
    
    // MARK: - User Actions
    
    func loadNotes() {
        isLoading = true
        Task {
            await interactor?.fetchNotes(request: NoteScene.FetchNotes.Request())
        }
    }
    
    func createNote(amount: Double, description: String, category: String, isIncome: Bool) {
        Task {
            let request = NoteScene.CreateNote.Request(
                amount: amount,
                description: description,
                category: category,
                isIncome: isIncome
            )
            await interactor?.createNote(request: request)
        }
    }
    
    func updateNote(noteId: String, amount: Double, description: String, category: String) {
        Task {
            let request = NoteScene.UpdateNote.Request(
                noteId: noteId,
                amount: amount,
                description: description,
                category: category
            )
            await interactor?.updateNote(request: request)
        }
    }
    
    func deleteNote(noteId: String) {
        Task {
            let request = NoteScene.DeleteNote.Request(noteId: noteId)
            await interactor?.deleteNote(request: request)
        }
    }
}

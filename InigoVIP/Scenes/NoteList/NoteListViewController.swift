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
    
    // Display Method
    func displayNotes(viewModel: NoteScene.FetchNotes.ViewModel) {
        displayedNotes = viewModel.displayedNotes
        isLoading = false
    }
    
    func displayCreateResult(viewModel: NoteScene.CreateNote.ViewModel) {
        // Not used in list
    }
    
    func displayUpdateResult(viewModel: NoteScene.UpdateNote.ViewModel) {
        // Not used in list
    }
    
    func displayDeleteResult(viewModel: NoteScene.DeleteNote.ViewModel) {
        if viewModel.success {
            // Refresh list after delete
            loadNotes()
        } else {
            errorMessage = viewModel.message
        }
    }
    
    func displayNote(viewModel: NoteScene.FetchNote.ViewModel) {
        // Not used in list
    }
    
    // User Actions
    func loadNotes() {
        isLoading = true
        Task {
            await interactor?.fetchNotes(request: NoteScene.FetchNotes.Request())
        }
    }
    
    func deleteNote(noteId: String) {
        Task {
            let request = NoteScene.DeleteNote.Request(noteId: noteId)
            await interactor?.deleteNote(request: request)
        }
    }
}

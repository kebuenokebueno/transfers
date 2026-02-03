//
//  NoteListPresenter.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation

protocol NotePresentationLogic {
    func presentNotes(response: NoteScene.FetchNotes.Response)
    func presentCreateResult(response: NoteScene.CreateNote.Response)
    func presentUpdateResult(response: NoteScene.UpdateNote.Response)
    func presentDeleteResult(response: NoteScene.DeleteNote.Response)
    func presentNote(response: NoteScene.FetchNote.Response)
}

@MainActor
class NoteListPresenter: NotePresentationLogic {
    weak var viewController: NoteDisplayLogic?
    
    // MARK: - Present Notes
    
    func presentNotes(response: NoteScene.FetchNotes.Response) {
        let displayedNotes = response.notes.map { note in
            NoteScene.FetchNotes.ViewModel.DisplayedNote(
                id: note.id,
                amount: formatAmount(note.amount),
                description: note.noteDescription,
                date: formatDate(note.date),
                category: note.category,
                isPositive: note.isPositive,
                syncStatus: note.syncStatusEnum.rawValue.capitalized
            )
        }
        
        let viewModel = NoteScene.FetchNotes.ViewModel(
            displayedNotes: displayedNotes,
            totalCount: displayedNotes.count,
        )
        
        viewController?.displayNotes(viewModel: viewModel)
    }
    
    // MARK: - Present Create Result
    
    func presentCreateResult(response: NoteScene.CreateNote.Response) {
        let viewModel = NoteScene.CreateNote.ViewModel(
            success: response.success,
            message: response.success ? "Note created successfully" : "Failed to create note"
        )
        viewController?.displayCreateResult(viewModel: viewModel)
    }
    
    // MARK: - Present Update Result
    
    func presentUpdateResult(response: NoteScene.UpdateNote.Response) {
        let viewModel = NoteScene.UpdateNote.ViewModel(
            success: response.success,
            message: response.success ? "Note updated successfully" : "Failed to update note"
        )
        viewController?.displayUpdateResult(viewModel: viewModel)
    }
    
    // MARK: - Present Delete Result
    
    func presentDeleteResult(response: NoteScene.DeleteNote.Response) {
        let viewModel = NoteScene.DeleteNote.ViewModel(
            success: response.success,
            message: response.success ? "Note deleted successfully" : "Failed to delete note"
        )
        viewController?.displayDeleteResult(viewModel: viewModel)
    }
    
    // MARK: - Present Single Note
    
    func presentNote(response: NoteScene.FetchNote.Response) {
        let displayedNote = response.note.map { note in
            NoteScene.FetchNote.ViewModel.DisplayedNote(
                id: note.id,
                amount: formatAmount(note.amount),
                description: note.noteDescription,
                date: formatDate(note.date),
                category: note.category,
                isPositive: note.isPositive,
                syncStatus: note.syncStatusEnum.rawValue.capitalized
            )
        }
        
        let viewModel = NoteScene.FetchNote.ViewModel(displayedNote: displayedNote)
        viewController?.displayNote(viewModel: viewModel)
    }
    
    // MARK: - Formatting Helpers
    
    private func formatAmount(_ amount: Double) -> String {
        let absAmount = abs(amount)
        let formatted = String(format: "%.2f", absAmount)
        return amount >= 0 ? "+€\(formatted)" : "-€\(formatted)"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

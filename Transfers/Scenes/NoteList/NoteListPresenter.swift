//
//  NoteListPresenter.swift
//  Transfers
//

import Foundation

protocol NoteListPresentationLogic {
    func presentNotes(response: NoteScene.FetchNotes.Response)
    func presentDeleteResult(response: NoteScene.DeleteNote.Response)
}

@MainActor
class NoteListPresenter: NoteListPresentationLogic {
    weak var viewController: NoteListDisplayLogic?

    func presentNotes(response: NoteScene.FetchNotes.Response) {
        let displayedNotes = response.notes.map { note in
            NoteViewModel(
                id: note.id,
                amount: formatAmount(note.amount),
                description: note.noteDescription,
                date: formatDate(note.date),
                category: note.category,
                isPositive: note.isPositive,
                syncStatus: note.syncStatusEnum.rawValue.capitalized
            )
        }
        let viewModel = NoteScene.FetchNotes.ViewModel(displayedNotes: displayedNotes)
        viewController?.displayNotes(viewModel: viewModel)
    }

    func presentDeleteResult(response: NoteScene.DeleteNote.Response) {
        let viewModel = NoteScene.DeleteNote.ViewModel(
            success: response.success,
            message: response.success ? "Note deleted" : "Failed to delete note"
        )
        viewController?.displayDeleteResult(viewModel: viewModel)
    }

    private func formatAmount(_ amount: Double) -> String {
        let formatted = String(format: "%.2f", abs(amount))
        return amount >= 0 ? "+€\(formatted)" : "-€\(formatted)"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

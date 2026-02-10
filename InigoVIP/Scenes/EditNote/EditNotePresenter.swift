//
//  EditNotePresenter.swift
//  InigoVIP
//

import Foundation

protocol EditNotePresentationLogic {
    func presentNote(response: EditNoteScene.LoadNote.Response)
    func presentSaveResult(response: EditNoteScene.SaveNote.Response)
}

protocol EditNoteDisplayLogic: AnyObject {
    func displayNote(viewModel: EditNoteScene.LoadNote.ViewModel)
    func displaySaveResult(viewModel: EditNoteScene.SaveNote.ViewModel)
}

@MainActor
class EditNotePresenter: EditNotePresentationLogic {
    weak var viewController: EditNoteDisplayLogic?

    func presentNote(response: EditNoteScene.LoadNote.Response) {
        guard let note = response.note else {
            viewController?.displayNote(viewModel: .init(note: nil, amount: "", description: "", category: ""))
            return
        }
        let vm = NoteViewModel(
            id: note.id,
            amount: formatAmount(note.amount),
            description: note.noteDescription,
            date: formatDate(note.date),
            category: note.category,
            isPositive: note.isPositive,
            syncStatus: note.syncStatusEnum.rawValue.capitalized
        )
        viewController?.displayNote(viewModel: .init(
            note: vm,
            amount: String(abs(note.amount)),
            description: note.noteDescription,
            category: note.category
        ))
    }

    func presentSaveResult(response: EditNoteScene.SaveNote.Response) {
        let vm = EditNoteScene.SaveNote.ViewModel(
            success: response.success,
            message: response.success ? "Note updated successfully" : "Failed to update note"
        )
        viewController?.displaySaveResult(viewModel: vm)
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

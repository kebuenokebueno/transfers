//
//  NoteDetailPresenter.swift
//  Transfers
//

import Foundation

protocol NoteDetailPresentationLogic {
    func presentNote(response: NoteDetailScene.FetchNote.Response)
    func presentDeleteResult(response: NoteDetailScene.DeleteNote.Response)
}

@MainActor
class NoteDetailPresenter: NoteDetailPresentationLogic {
    weak var viewController: NoteDetailDisplayLogic?

    func presentNote(response: NoteDetailScene.FetchNote.Response) {
        let vm = response.note.map { note in
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
        viewController?.displayNote(viewModel: .init(note: vm))
    }

    func presentDeleteResult(response: NoteDetailScene.DeleteNote.Response) {
        let vm = NoteDetailScene.DeleteNote.ViewModel(
            success: response.success,
            message: response.success ? "Note deleted" : "Failed to delete note"
        )
        viewController?.displayDeleteResult(viewModel: vm)
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

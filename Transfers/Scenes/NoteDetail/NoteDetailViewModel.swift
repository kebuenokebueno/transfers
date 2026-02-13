//
//  NoteDetailViewModel.swift
//  Transfers
//
//  MVVM ViewModel for NoteDetail scene
//

import Foundation

@MainActor
@Observable
final class NoteDetailViewModel {
    
    // MARK: - Dependencies
    
    private let noteWorker: NoteWorkerProtocol
    private let swiftDataService: SwiftDataServiceProtocol
    private let router: Router
    
    // MARK: - Published State
    
    private(set) var note: NoteViewModel?
    var errorMessage: String?
    
    // MARK: - Init
    
    init(
        noteWorker: NoteWorkerProtocol,
        swiftDataService: SwiftDataServiceProtocol,
        router: Router
    ) {
        self.noteWorker = noteWorker
        self.swiftDataService = swiftDataService
        self.router = router
    }
    
    // MARK: - User Actions
    
    func loadNote(noteId: String) {
        Task {
            await fetchNote(noteId: noteId)
        }
    }
    
    func deleteNote(noteId: String) {
        Task {
            await performDeleteNote(noteId: noteId)
        }
    }
    
    func didTapEdit(noteId: String) {
        router.navigate(to: .editNote(id: noteId))
    }
    
    // MARK: - Business Logic
    
    private func fetchNote(noteId: String) async {
        let entity = try? swiftDataService.fetchNote(id: noteId)
        note = entity.map { formatNote($0) }
    }
    
    private func performDeleteNote(noteId: String) async {
        await noteWorker.deleteNote(id: noteId)
        router.navigateBack()
    }
    
    // MARK: - Presentation Logic
    
    private func formatNote(_ note: NoteEntity) -> NoteViewModel {
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

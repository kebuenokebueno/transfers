//
//  NoteListViewModel.swift
//  Transfers
//
//  MVVM ViewModel - combines business logic (Interactor), presentation (Presenter), and state (ViewController)
//

import Foundation

@MainActor
@Observable
final class NoteListViewModel {
    
    // MARK: - Dependencies
    
    private let noteWorker: NoteWorkerProtocol
    private let swiftDataService: SwiftDataServiceProtocol
    private let router: Router
    
    // MARK: - Published State
    
    private(set) var displayedNotes: [NoteViewModel] = []
    private(set) var isLoading = false
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
    
    func loadNotes() {
        isLoading = true
        Task {
            await fetchNotes()
        }
    }
    
    func deleteNote(noteId: String) {
        Task {
            await performDeleteNote(noteId: noteId)
        }
    }
    
    func didSelectNote(noteId: String) {
        router.navigate(to: .noteDetail(id: noteId))
    }
    
    func didTapAddNote() {
        router.present(sheet: .addNote)
    }
    
    func didTapEditNote(noteId: String) {
        router.navigate(to: .editNote(id: noteId))
    }
    
    // MARK: - Business Logic (from Interactor)
    
    private func fetchNotes() async {
        // Show local notes first (optimistic UI)
        let localNotes = (try? swiftDataService.fetchNotes()) ?? []
        if !localNotes.isEmpty {
            displayedNotes = formatNotes(localNotes)
        }
        
        // Sync with remote
        await noteWorker.fetchNotes()
        
        // Update with synced notes
        let updatedNotes = (try? swiftDataService.fetchNotes()) ?? []
        displayedNotes = formatNotes(updatedNotes)
        isLoading = false
    }
    
    private func performDeleteNote(noteId: String) async {
        await noteWorker.deleteNote(id: noteId)
        // Refresh list after deletion
        await fetchNotes()
    }
    
    // MARK: - Presentation Logic (from Presenter)
    
    private func formatNotes(_ notes: [NoteEntity]) -> [NoteViewModel] {
        notes.map { note in
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

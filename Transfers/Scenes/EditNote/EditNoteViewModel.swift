//
//  EditNoteViewModel.swift
//  Transfers
//
//  MVVM ViewModel for EditNote scene
//

import Foundation

@MainActor
@Observable
final class EditNoteViewModel {
    
    // MARK: - Dependencies
    
    private let noteWorker: NoteWorkerProtocol
    private let swiftDataService: SwiftDataServiceProtocol
    private let router: Router
    
    // MARK: - Published State (Form Fields)
    
    var amount = ""
    var description = ""
    var category = ""
    var isPositive = true
    
    // MARK: - Published State (UI State)
    
    private(set) var isLoading = true
    private(set) var isSaving = false
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
    
    func saveNote(noteId: String) {
        guard let value = Double(amount) else { return }
        isSaving = true
        Task {
            await performSaveNote(
                noteId: noteId,
                amount: value,
                description: description,
                category: category,
                isPositive: isPositive
            )
        }
    }
    
    // MARK: - Business Logic
    
    private func fetchNote(noteId: String) async {
        guard let note = try? swiftDataService.fetchNote(id: noteId) else {
            amount = ""
            description = ""
            category = ""
            isLoading = false
            return
        }
        
        amount = String(abs(note.amount))
        description = note.noteDescription
        category = note.category
        isPositive = note.isPositive
        isLoading = false
    }
    
    private func performSaveNote(
        noteId: String,
        amount: Double,
        description: String,
        category: String,
        isPositive: Bool
    ) async {
        guard let existing = try? swiftDataService.fetchNote(id: noteId) else {
            isSaving = false
            errorMessage = "Failed to update note"
            return
        }
        
        existing.amount = isPositive ? amount : -amount
        existing.noteDescription = description
        existing.category = category
        
        await noteWorker.updateNote(existing)
        
        isSaving = false
        router.navigateBack()
    }
}

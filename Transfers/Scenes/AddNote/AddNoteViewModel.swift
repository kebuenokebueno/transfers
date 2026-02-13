//
//  AddNoteViewModel.swift
//  Transfers
//
//  MVVM ViewModel for AddNote scene
//

import Foundation

@MainActor
@Observable
final class AddNoteViewModel {
    
    // MARK: - Dependencies
    
    private let noteWorker: NoteWorkerProtocol
    private let router: Router
    
    // MARK: - Published State
    
    private(set) var isSaving = false
    var errorMessage: String?
    
    // MARK: - Init
    
    init(noteWorker: NoteWorkerProtocol, router: Router) {
        self.noteWorker = noteWorker
        self.router = router
    }
    
    // MARK: - User Actions
    
    func saveNote(amount: Double, description: String, category: String, isIncome: Bool) {
        isSaving = true
        Task {
            await performSaveNote(
                amount: amount,
                description: description,
                category: category,
                isIncome: isIncome
            )
        }
    }
    
    func dismiss() {
        router.dismiss()
    }
    
    // MARK: - Business Logic
    
    private func performSaveNote(
        amount: Double,
        description: String,
        category: String,
        isIncome: Bool
    ) async {
        let note = NoteEntity(
            id: UUID().uuidString,
            amount: isIncome ? amount : -amount,
            description: description,
            date: Date(),
            category: category,
            syncStatus: .pending
        )
        
        await noteWorker.createNote(note)
        
        isSaving = false
        router.dismiss()
    }
}

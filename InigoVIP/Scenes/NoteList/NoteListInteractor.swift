//
//  NoteListInteractor.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation

@MainActor
class NoteListInteractor: NoteBusinessLogic {
    var presenter: NotePresentationLogic?
    private let noteWorker: NoteWorkerProtocol
    private let swiftDataService: SwiftDataServiceProtocol
    
    init(noteWorker: NoteWorkerProtocol, swiftDataService: SwiftDataServiceProtocol) {
        self.noteWorker = noteWorker
        self.swiftDataService = swiftDataService
    }
    
    // MARK: - Fetch Notes
    
    func fetchNotes(request: NoteScene.FetchNotes.Request) async {
        // Fetch from SwiftData (local) first
        let localNotes = (try? swiftDataService.fetchNotes()) ?? []
        let isFromSwiftData = !localNotes.isEmpty
        
        // Present immediately with local data
        if isFromSwiftData {
            let response = NoteScene.FetchNotes.Response(
                notes: localNotes,
            )
            presenter?.presentNotes(response: response)
        }
        
        // Sync from cloud in background
        await noteWorker.fetchNotes()
        
        // Fetch updated notes from SwiftData
        let updatedNotes = (try? swiftDataService.fetchNotes()) ?? []
        let response = NoteScene.FetchNotes.Response(
            notes: updatedNotes,
        )
        presenter?.presentNotes(response: response)
    }
    
    // MARK: - Create Note
    
    func createNote(request: NoteScene.CreateNote.Request) async {
        let note = Note(
            id: UUID().uuidString,
            amount: request.isIncome ? request.amount : -request.amount,
            description: request.description,
            date: Date(),
            category: request.category,
            syncStatus: .pending
        )
        
        await noteWorker.createNote(note)
        
        let response = NoteScene.CreateNote.Response(
            note: note,
            success: true
        )
        presenter?.presentCreateResult(response: response)
    }
    
    // MARK: - Update Note
    
    func updateNote(request: NoteScene.UpdateNote.Request) async {
        // Fetch note from SwiftData
        guard let note = try? swiftDataService.fetchNote(id: request.noteId) else {
            let dummyNote = Note(
                id: UUID().uuidString,
                amount: request.amount,
                description: request.description,
                date: Date(),
                category: request.category
            )
            let response = NoteScene.UpdateNote.Response(
                note: dummyNote,
                success: false
            )
            presenter?.presentUpdateResult(response: response)
            return
        }
        
        // Update note properties
        note.syncStatus = "pending"
        note.amount = request.amount
        note.noteDescription = request.description
        note.category = request.category
        
        await noteWorker.updateNote(note)
        
        let response = NoteScene.UpdateNote.Response(
            note: note,
            success: true
        )
        presenter?.presentUpdateResult(response: response)
    }
    
    // MARK: - Delete Note
    
    func deleteNote(request: NoteScene.DeleteNote.Request) async {
        await noteWorker.deleteNote(id: request.noteId)
        
        let response = NoteScene.DeleteNote.Response(
            success: true,
            noteId: request.noteId
        )
        presenter?.presentDeleteResult(response: response)
    }

    // MARK: - Fetch Single Note
    
    func fetchNote(request: NoteScene.FetchNote.Request) async {
        // Fetch from SwiftData
        let note = try? swiftDataService.fetchNote(id: request.noteId)
        
        let response = NoteScene.FetchNote.Response(note: note)
        presenter?.presentNote(response: response)
    }
}

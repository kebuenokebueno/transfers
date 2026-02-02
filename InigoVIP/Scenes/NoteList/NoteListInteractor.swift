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
    private let noteManager: NoteManager
    
    init(noteManager: NoteManager) {
        self.noteManager = noteManager
    }
    
    // MARK: - Fetch Notes
    
    func fetchNotes(request: NoteScene.FetchNotes.Request) async {
        // Fetch from local first
        let localNotes = noteManager.notes
        let isFromCache = !localNotes.isEmpty
        
        // Present immediately with local data
        if isFromCache {
            let response = NoteScene.FetchNotes.Response(
                notes: localNotes,
                isFromCache: true
            )
            presenter?.presentNotes(response: response)
        }
        
        // Fetch from cloud
        await noteManager.fetchNotes()
        
        let response = NoteScene.FetchNotes.Response(
            notes: noteManager.notes,
            isFromCache: false
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
            category: request.category
        )
        
        await noteManager.createNote(note)
        
        let response = NoteScene.CreateNote.Response(
            note: note,
            success: true
        )
        presenter?.presentCreateResult(response: response)
    }
    
    // MARK: - Update Note
    
    func updateNote(request: NoteScene.UpdateNote.Request) async {
        guard let note = noteManager.notes.first(where: { $0.id == request.noteId }) else {
            let response = NoteScene.UpdateNote.Response(
                note: Note(id: "", amount: 0, description: "", date: Date(), category: ""),
                success: false
            )
            presenter?.presentUpdateResult(response: response)
            return
        }
        
        note.amount = request.amount
        note.noteDescription = request.description
        note.category = request.category
        
        await noteManager.updateNote(note)
        
        let response = NoteScene.UpdateNote.Response(
            note: note,
            success: true
        )
        presenter?.presentUpdateResult(response: response)
    }
    
    // MARK: - Delete Note
    
    func deleteNote(request: NoteScene.DeleteNote.Request) async {
        await noteManager.deleteNote(id: request.noteId)
        
        let response = NoteScene.DeleteNote.Response(
            success: true,
            noteId: request.noteId
        )
        presenter?.presentDeleteResult(response: response)
    }
    
    // MARK: - Fetch Single Note
    
    func fetchNote(request: NoteScene.FetchNote.Request) async {
        let note = noteManager.notes.first { $0.id == request.noteId }
        
        let response = NoteScene.FetchNote.Response(note: note)
        presenter?.presentNote(response: response)
    }
}

//
//  EditNoteInteractor.swift
//  Transfers
//

import Foundation

protocol EditNoteBusinessLogic {
    func loadNote(request: EditNoteScene.LoadNote.Request) async
    func saveNote(request: EditNoteScene.SaveNote.Request) async
}

@MainActor
class EditNoteInteractor: EditNoteBusinessLogic {
    var presenter: EditNotePresentationLogic?
    var noteId: String?

    private let noteWorker: NoteWorkerProtocol
    private let swiftDataService: SwiftDataServiceProtocol

    init(noteWorker: NoteWorkerProtocol, swiftDataService: SwiftDataServiceProtocol) {
        self.noteWorker = noteWorker
        self.swiftDataService = swiftDataService
    }

    func loadNote(request: EditNoteScene.LoadNote.Request) async {
        let note = try? swiftDataService.fetchNote(id: request.noteId)
        let response = EditNoteScene.LoadNote.Response(note: note)
        await MainActor.run { presenter?.presentNote(response: response) }
    }

    func saveNote(request: EditNoteScene.SaveNote.Request) async {
        guard let existing = try? swiftDataService.fetchNote(id: request.noteId) else {
            let response = EditNoteScene.SaveNote.Response(success: false)
            await MainActor.run { presenter?.presentSaveResult(response: response) }
            return
        }
        existing.amount = request.isPositive ? request.amount : -request.amount
        existing.noteDescription = request.description
        existing.category = request.category
        await noteWorker.updateNote(existing)
        let response = EditNoteScene.SaveNote.Response(success: true)
        await MainActor.run { presenter?.presentSaveResult(response: response) }
    }
}

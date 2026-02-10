//
//  NoteListInteractor.swift
//  InigoVIP
//

import Foundation

protocol NoteListBusinessLogic {
    func fetchNotes() async
    func deleteNote(request: NoteScene.DeleteNote.Request) async
}

// DataStore: exposes data the Router needs to pass to other scenes
protocol NoteListDataStore: AnyObject {
    var selectedNoteId: String? { get set }
}

@MainActor
class NoteListInteractor: NoteListBusinessLogic, NoteListDataStore {
    var presenter: NoteListPresentationLogic?
    var selectedNoteId: String?                       // ← Router reads this

    private let noteWorker: NoteWorkerProtocol
    private let swiftDataService: SwiftDataServiceProtocol

    init(noteWorker: NoteWorkerProtocol, swiftDataService: SwiftDataServiceProtocol) {
        self.noteWorker = noteWorker
        self.swiftDataService = swiftDataService
    }

    // MARK: - Fetch Notes

    func fetchNotes() async {
        let localNotes = (try? swiftDataService.fetchNotes()) ?? []
        if !localNotes.isEmpty {
            let response = NoteScene.FetchNotes.Response(notes: localNotes)
            await MainActor.run { presenter?.presentNotes(response: response) }
        }
        await noteWorker.fetchNotes()
        let updatedNotes = (try? swiftDataService.fetchNotes()) ?? []
        let response = NoteScene.FetchNotes.Response(notes: updatedNotes)
        await MainActor.run { presenter?.presentNotes(response: response) }
    }

    // MARK: - Delete Note

    func deleteNote(request: NoteScene.DeleteNote.Request) async {
        await noteWorker.deleteNote(id: request.noteId)
        let response = NoteScene.DeleteNote.Response(success: true, noteId: request.noteId)
        await MainActor.run { presenter?.presentDeleteResult(response: response) }
    }
}

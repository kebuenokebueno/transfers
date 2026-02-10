//
//  NoteDetailInteractor.swift
//  InigoVIP
//

import Foundation

protocol NoteDetailBusinessLogic {
    func fetchNote(request: NoteDetailScene.FetchNote.Request) async
    func deleteNote(request: NoteDetailScene.DeleteNote.Request) async
}

protocol NoteDetailDataStore: AnyObject {
    var noteId: String? { get set }
}

@MainActor
class NoteDetailInteractor: NoteDetailBusinessLogic, NoteDetailDataStore {
    var presenter: NoteDetailPresentationLogic?
    var noteId: String?                               // ← set by NoteListRouter

    private let noteWorker: NoteWorkerProtocol
    private let swiftDataService: SwiftDataServiceProtocol

    init(noteWorker: NoteWorkerProtocol, swiftDataService: SwiftDataServiceProtocol) {
        self.noteWorker = noteWorker
        self.swiftDataService = swiftDataService
    }

    func fetchNote(request: NoteDetailScene.FetchNote.Request) async {
        let note = try? swiftDataService.fetchNote(id: request.noteId)
        let response = NoteDetailScene.FetchNote.Response(note: note)
        await MainActor.run { presenter?.presentNote(response: response) }
    }

    func deleteNote(request: NoteDetailScene.DeleteNote.Request) async {
        await noteWorker.deleteNote(id: request.noteId)
        let response = NoteDetailScene.DeleteNote.Response(success: true)
        await MainActor.run { presenter?.presentDeleteResult(response: response) }
    }
}

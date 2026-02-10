//
//  AddNoteInteractor.swift
//  InigoVIP
//

import Foundation

protocol AddNoteBusinessLogic {
    func saveNote(request: AddNoteScene.SaveNote.Request) async
}

protocol AddNoteDataStore: AnyObject {}

@MainActor
class AddNoteInteractor: AddNoteBusinessLogic, AddNoteDataStore {
    var presenter: AddNotePresentationLogic?

    private let noteWorker: NoteWorkerProtocol

    init(noteWorker: NoteWorkerProtocol) {
        self.noteWorker = noteWorker
    }

    func saveNote(request: AddNoteScene.SaveNote.Request) async {
        let note = NoteEntity(
            id: UUID().uuidString,
            amount: request.isIncome ? request.amount : -request.amount,
            description: request.description,
            date: Date(),
            category: request.category,
            syncStatus: .pending
        )
        await noteWorker.createNote(note)
        let response = AddNoteScene.SaveNote.Response(success: true)
        await MainActor.run { presenter?.presentSaveResult(response: response) }
    }
}

//
//  NoteDetailInteractorTests.swift
//  InigoVIPTests
//

import Testing
import Foundation
@testable import InigoVIP

@MainActor
@Suite("NoteDetail Interactor Tests", .tags(.unit, .interactor))
struct NoteDetailInteractorTests {

    private func makeSUT() -> (
        interactor: NoteDetailInteractor,
        presenter: MockNoteDetailPresenter,
        worker: MockNoteWorker,
        swiftData: MockSwiftDataService
    ) {
        let swiftData  = MockSwiftDataService()
        let supabase   = MockSupabaseService()
        let worker     = MockNoteWorker(swiftDataService: swiftData, supabaseService: supabase)
        let interactor = NoteDetailInteractor(noteWorker: worker, swiftDataService: swiftData)
        let presenter  = MockNoteDetailPresenter()
        interactor.presenter = presenter
        return (interactor, presenter, worker, swiftData)
    }

    // MARK: - Fetch Note

    @Test("Fetch note – returns correct note")
    func fetchNoteSuccess() async {
        let (interactor, presenter, _, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedNotes())

        await interactor.fetchNote(request: NoteDetailScene.FetchNote.Request(noteId: "3"))

        #expect(presenter.presentNoteCalled == true)
        #expect(presenter.lastFetchResponse?.note?.id == "3")
        #expect(presenter.lastFetchResponse?.note?.noteDescription == "Salary")
    }

    @Test("Fetch note – missing id returns nil")
    func fetchNoteMissing() async {
        let (interactor, presenter, _, _) = makeSUT()

        await interactor.fetchNote(request: NoteDetailScene.FetchNote.Request(noteId: "missing"))

        #expect(presenter.presentNoteCalled == true)
        #expect(presenter.lastFetchResponse?.note == nil)
    }

    @Test("Fetch note – nil presenter does not crash")
    func fetchNoteNilPresenter() async {
        let (interactor, _, _, swiftData) = makeSUT()
        interactor.presenter = nil
        swiftData.seed(TestDataBuilder.createMixedNotes())

        await interactor.fetchNote(request: NoteDetailScene.FetchNote.Request(noteId: "1"))
        #expect(true)
    }

    // MARK: - Delete Note

    @Test("Delete note – removes from SwiftData and calls presenter")
    func deleteNoteSuccess() async {
        let (interactor, presenter, worker, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedNotes())

        await interactor.deleteNote(request: NoteDetailScene.DeleteNote.Request(noteId: "3"))

        #expect(presenter.presentDeleteResultCalled == true)
        #expect(presenter.lastDeleteResponse?.success == true)
        #expect(worker.deleteNoteCallCount == 1)
        #expect(swiftData.notes.contains(where: { $0.id == "3" }) == false)
    }

    @Test("Delete note – non-existent id still reports success")
    func deleteNoteNotFound() async {
        let (interactor, presenter, _, _) = makeSUT()

        await interactor.deleteNote(request: NoteDetailScene.DeleteNote.Request(noteId: "ghost"))

        #expect(presenter.presentDeleteResultCalled == true)
        #expect(presenter.lastDeleteResponse?.success == true)
    }

    @Test("Delete note – nil presenter does not crash")
    func deleteNoteNilPresenter() async {
        let (interactor, _, _, swiftData) = makeSUT()
        interactor.presenter = nil
        swiftData.seed([TestDataBuilder.createNote(id: "x")])

        await interactor.deleteNote(request: NoteDetailScene.DeleteNote.Request(noteId: "x"))
        #expect(true)
    }
}

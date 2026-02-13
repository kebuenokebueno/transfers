//
//  NoteListInteractorTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("NoteList Interactor Tests", .tags(.unit, .interactor))
struct NoteListInteractorTests {

    private func makeSUT() -> (
        interactor: NoteListInteractor,
        presenter: MockNoteListPresenter,
        worker: MockNoteWorker,
        swiftData: MockSwiftDataService
    ) {
        let swiftData  = MockSwiftDataService()
        let supabase   = MockSupabaseService()
        let worker     = MockNoteWorker(swiftDataService: swiftData, supabaseService: supabase)
        let interactor = NoteListInteractor(noteWorker: worker, swiftDataService: swiftData)
        let presenter  = MockNoteListPresenter()
        interactor.presenter = presenter
        return (interactor, presenter, worker, swiftData)
    }

    // MARK: - Fetch Notes

    @Test("Fetch notes - returns all notes from SwiftData")
    func fetchNotesSuccess() async {
        let (interactor, presenter, _, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedNotes())
        await interactor.fetchNotes()
        #expect(presenter.presentNotesCalled == true)
        #expect(presenter.lastFetchResponse?.notes.count == 5)
    }

    @Test("Fetch notes - empty SwiftData still calls presenter")
    func fetchNotesEmpty() async {
        let (interactor, presenter, _, _) = makeSUT()
        await interactor.fetchNotes()
        #expect(presenter.presentNotesCalled == true)
        #expect(presenter.lastFetchResponse?.notes.isEmpty == true)
    }

    @Test("Fetch notes - large dataset 1000 notes")
    func fetchNotesLargeDataset() async {
        let (interactor, presenter, _, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createNotes(count: 1000))
        await interactor.fetchNotes()
        #expect(presenter.lastFetchResponse?.notes.count == 1000)
    }

    @Test("Fetch notes - nil presenter does not crash")
    func fetchNotesNilPresenter() async {
        let (interactor, _, _, swiftData) = makeSUT()
        interactor.presenter = nil
        swiftData.seed(TestDataBuilder.createMixedNotes())
        await interactor.fetchNotes()
        #expect(true)
    }

    @Test("Fetch notes - presenter called once when empty")
    func fetchNotesCallCountEmpty() async {
        let (interactor, presenter, _, _) = makeSUT()
        await interactor.fetchNotes()
        #expect(presenter.presentNotesCallCount == 1)
    }

    @Test("Fetch notes - presenter called twice when SwiftData has data")
    func fetchNotesCallCountWithData() async {
        let (interactor, presenter, _, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedNotes())
        await interactor.fetchNotes()
        #expect(presenter.presentNotesCallCount == 2)
    }

    // MARK: - Delete Note

    @Test("Delete note - removes from SwiftData and calls presenter")
    func deleteNoteSuccess() async {
        let (interactor, presenter, worker, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedNotes())
        await interactor.deleteNote(request: NoteScene.DeleteNote.Request(noteId: "3"))
        #expect(presenter.presentDeleteResultCalled == true)
        #expect(presenter.lastDeleteResponse?.success == true)
        #expect(presenter.lastDeleteResponse?.noteId == "3")
        #expect(swiftData.notes.count == 4)
        #expect(swiftData.notes.contains(where: { $0.id == "3" }) == false)
        #expect(worker.deleteNoteCallCount == 1)
    }

    @Test("Delete note - non-existent id still reports success")
    func deleteNoteNotFound() async {
        let (interactor, presenter, _, _) = makeSUT()
        await interactor.deleteNote(request: NoteScene.DeleteNote.Request(noteId: "ghost"))
        #expect(presenter.presentDeleteResultCalled == true)
    }

    @Test("Delete note - delete all notes one by one")
    func deleteNoteAll() async {
        let (interactor, _, _, swiftData) = makeSUT()
        let notes = TestDataBuilder.createMixedNotes()
        swiftData.seed(notes)
        for note in notes {
            await interactor.deleteNote(request: NoteScene.DeleteNote.Request(noteId: note.id))
        }
        #expect(swiftData.notes.isEmpty)
    }
}

//
//  NoteListInteractorTests.swift
//  InigoVIPTests
//
//  Created by Inigo on 29/1/26.
//

import Testing
import Foundation
@testable import InigoVIP

// MARK: - Interactor Tests
@MainActor
@Suite("NoteList Interactor Tests", .tags(.unit, .interactor))
struct NoteListInteractorTests {

    // ---------------------------------------------------------------------------
    // MARK: - Helper: builds a wired-up Interactor with mocks
    // ---------------------------------------------------------------------------
    @MainActor
    private func makeSUT() -> (
        interactor: NoteListInteractor,
        presenter: MockNoteListPresenter,
        worker: MockNoteWorker,
        swiftData: MockSwiftDataService
    ) {
        let swiftData = MockSwiftDataService()
        let supabase  = MockSupabaseService()
        let worker    = MockNoteWorker(swiftDataService: swiftData, supabaseService: supabase)
        let interactor = NoteListInteractor(noteWorker: worker, swiftDataService: swiftData)
        let presenter  = MockNoteListPresenter()
        interactor.presenter = presenter
        return (interactor, presenter, worker, swiftData)
    }

    // =========================================================================
    // MARK: - Fetch Notes
    // =========================================================================
    @MainActor
    @Test("Fetch notes – returns all notes from SwiftData")
    func fetchNotesSuccess() async {
        let (interactor, presenter, _, swiftData) = makeSUT()
        let notes = TestDataBuilder.createMixedNotes()
        swiftData.seed(notes)

        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())

        #expect(presenter.presentNotesCalled == true)
        #expect(presenter.lastFetchResponse?.notes.count == 5)
    }
    @MainActor
    @Test("Fetch notes – empty SwiftData returns empty response")
    func fetchNotesEmpty() async {
        let (interactor, presenter, _, _) = makeSUT()

        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())

        #expect(presenter.presentNotesCalled == true)
        #expect(presenter.lastFetchResponse?.notes.isEmpty == true)
    }
    @MainActor
    @Test("Fetch notes – large dataset (1 000 notes)")
    func fetchNotesLargeDataset() async {
        let (interactor, presenter, _, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createNotes(count: 1000))

        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())

        #expect(presenter.lastFetchResponse?.notes.count == 1000)
    }
    @MainActor
    @Test("Fetch notes – nil presenter does not crash")
    func fetchNotesNilPresenter() async {
        let (interactor, _, _, swiftData) = makeSUT()
        interactor.presenter = nil                          // deliberately nil
        swiftData.seed(TestDataBuilder.createMixedNotes())

        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())
        // success = no crash
        #expect(true)
    }

    // =========================================================================
    // MARK: - Create Note
    // =========================================================================
    @MainActor
    @Test("Create note – persists to SwiftData and calls presenter")
    func createNoteSuccess() async {
        let (interactor, presenter, worker, swiftData) = makeSUT()

        let request = NoteScene.CreateNote.Request(
            amount: 75.00,
            description: "Coffee Shop",
            category: "Food",
            isIncome: false
        )

        await interactor.createNote(request: request)

        // Presenter told about the new note
        #expect(presenter.presentCreateResultCalled == true)
        #expect(presenter.lastCreateResponse?.success == true)

        // Actually landed in SwiftData
        #expect(swiftData.notes.count == 1)
        #expect(swiftData.notes.first?.noteDescription == "Coffee Shop")
        #expect(swiftData.notes.first?.amount == -75.00, "Expense should be negative")

        // Worker.createNote was called
        #expect(worker.createNoteCallCount == 1)
    }
    @MainActor
    @Test("Create note – income flag keeps amount positive")
    func createNoteIncome() async {
        let (interactor, presenter, _, swiftData) = makeSUT()

        let request = NoteScene.CreateNote.Request(
            amount: 2500.00,
            description: "Salary",
            category: "Income",
            isIncome: true
        )

        await interactor.createNote(request: request)

        #expect(presenter.lastCreateResponse?.success == true)
        #expect(swiftData.notes.first?.amount == 2500.00)
    }

    @MainActor
    @Test("Create note – multiple notes accumulate")
    func createNoteMultiple() async {
        let (interactor, _, _, swiftData) = makeSUT()

        for i in 1...3 {
            await interactor.createNote(request: NoteScene.CreateNote.Request(
                amount: Double(i * 10),
                description: "Note \(i)",
                category: "Food",
                isIncome: false
            ))
        }

        #expect(swiftData.notes.count == 3)
    }

    // =========================================================================
    // MARK: - Update Note
    // =========================================================================

    @MainActor
    @Test("Update note – changes persist to SwiftData")
    func updateNoteSuccess() async {
        let (interactor, presenter, worker, swiftData) = makeSUT()

        // Seed an existing note
        let original = TestDataBuilder.createNote(id: "upd_1", amount: -50.00, description: "Old Name", category: "Food")
        swiftData.seed([original])

        let request = NoteScene.UpdateNote.Request(
            noteId: "upd_1",
            amount: 99.99,
            description: "New Name",
            category: "Entertainment"
        )

        await interactor.updateNote(request: request)

        // Presenter told success
        #expect(presenter.presentUpdateResultCalled == true)
        #expect(presenter.lastUpdateResponse?.success == true)

        // SwiftData reflects the update
        let updated = swiftData.notes.first(where: { $0.id == "upd_1" })
        #expect(updated?.noteDescription == "New Name")
        #expect(updated?.category == "Entertainment")
        #expect(updated?.amount == 99.99)

        // Worker was invoked
        #expect(worker.updateNoteCallCount == 1)
    }

    @MainActor
    @Test("Update note – non-existent id reports failure")
    func updateNoteNotFound() async {
        let (interactor, presenter, _, _) = makeSUT()
        // SwiftData is empty – note doesn't exist

        let request = NoteScene.UpdateNote.Request(
            noteId: "ghost",
            amount: 10.00,
            description: "Ghost",
            category: "Other"
        )

        await interactor.updateNote(request: request)

        #expect(presenter.presentUpdateResultCalled == true)
        #expect(presenter.lastUpdateResponse?.success == false)
    }

    @MainActor
    @Test("Update note – sync status set to pending")
    func updateNoteSetsPending() async {
        let (interactor, _, _, swiftData) = makeSUT()

        let original = TestDataBuilder.createNote(id: "sync_1", syncStatus: "synced")
        swiftData.seed([original])

        await interactor.updateNote(request: NoteScene.UpdateNote.Request(
            noteId: "sync_1",
            amount: 1.00,
            description: "Trigger sync",
            category: "Other"
        ))

        let updated = swiftData.notes.first(where: { $0.id == "sync_1" })
        #expect(updated?.syncStatus == "pending")
    }

    // =========================================================================
    // MARK: - Delete Note
    // =========================================================================

    @MainActor
    @Test("Delete note – removes from SwiftData and calls presenter")
    func deleteNoteSuccess() async {
        let (interactor, presenter, worker, swiftData) = makeSUT()

        swiftData.seed(TestDataBuilder.createMixedNotes())   // 5 notes
        #expect(swiftData.notes.count == 5)

        await interactor.deleteNote(request: NoteScene.DeleteNote.Request(noteId: "3"))

        // Presenter told success
        #expect(presenter.presentDeleteResultCalled == true)
        #expect(presenter.lastDeleteResponse?.success == true)
        #expect(presenter.lastDeleteResponse?.noteId == "3")

        // Gone from SwiftData
        #expect(swiftData.notes.count == 4)
        #expect(swiftData.notes.contains(where: { $0.id == "3" }) == false)

        // Worker was invoked
        #expect(worker.deleteNoteCallCount == 1)
    }

    @MainActor
    @Test("Delete note – non-existent id still reports success (idempotent)")
    func deleteNoteNotFound() async {
        let (interactor, presenter, _, _) = makeSUT()
        // SwiftData is empty

        await interactor.deleteNote(request: NoteScene.DeleteNote.Request(noteId: "ghost"))

        // Interactor still tells presenter it's done (cloud delete is fire-and-forget)
        #expect(presenter.presentDeleteResultCalled == true)
    }

    @MainActor
    @Test("Delete note – delete all notes one by one")
    func deleteNoteAll() async {
        let (interactor, _, _, swiftData) = makeSUT()
        let notes = TestDataBuilder.createMixedNotes()
        swiftData.seed(notes)

        for note in notes {
            await interactor.deleteNote(request: NoteScene.DeleteNote.Request(noteId: note.id))
        }

        #expect(swiftData.notes.isEmpty)
    }

    // =========================================================================
    // MARK: - Fetch Single Note
    // =========================================================================

    @MainActor
    @Test("Fetch single note – returns correct note")
    func fetchNoteSuccess() async {
        let (interactor, presenter, _, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedNotes())

        await interactor.fetchNote(request: NoteScene.FetchNote.Request(noteId: "3"))

        #expect(presenter.presentNoteCalled == true)
        #expect(presenter.lastNoteResponse?.note?.id == "3")
        #expect(presenter.lastNoteResponse?.note?.noteDescription == "Salary")
    }

    @MainActor
    @Test("Fetch single note – missing id returns nil note")
    func fetchNoteMissing() async {
        let (interactor, presenter, _, _) = makeSUT()

        await interactor.fetchNote(request: NoteScene.FetchNote.Request(noteId: "missing"))

        #expect(presenter.presentNoteCalled == true)
        #expect(presenter.lastNoteResponse?.note == nil)
    }
}

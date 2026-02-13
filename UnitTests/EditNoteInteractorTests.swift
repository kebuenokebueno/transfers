//
//  EditNoteInteractorTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("EditNote Interactor Tests", .tags(.unit, .interactor))
struct EditNoteInteractorTests {

    private func makeSUT() -> (
        interactor: EditNoteInteractor,
        presenter: MockEditNotePresenter,
        worker: MockNoteWorker,
        swiftData: MockSwiftDataService
    ) {
        let swiftData  = MockSwiftDataService()
        let supabase   = MockSupabaseService()
        let worker     = MockNoteWorker(swiftDataService: swiftData, supabaseService: supabase)
        let interactor = EditNoteInteractor(noteWorker: worker, swiftDataService: swiftData)
        let presenter  = MockEditNotePresenter()
        interactor.presenter = presenter
        return (interactor, presenter, worker, swiftData)
    }

    // MARK: - Load Note

    @Test("Load note – returns correct note")
    func loadNoteSuccess() async {
        let (interactor, presenter, _, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedNotes())

        await interactor.loadNote(request: EditNoteScene.LoadNote.Request(noteId: "3"))

        #expect(presenter.presentNoteCalled == true)
        #expect(presenter.lastLoadResponse?.note?.id == "3")
        #expect(presenter.lastLoadResponse?.note?.noteDescription == "Salary")
    }

    @Test("Load note – missing id returns nil")
    func loadNoteMissing() async {
        let (interactor, presenter, _, _) = makeSUT()

        await interactor.loadNote(request: EditNoteScene.LoadNote.Request(noteId: "missing"))

        #expect(presenter.presentNoteCalled == true)
        #expect(presenter.lastLoadResponse?.note == nil)
    }

    // MARK: - Save Note

    @Test("Save note – changes persist to SwiftData")
    func saveNoteSuccess() async {
        let (interactor, presenter, worker, swiftData) = makeSUT()
        let original = TestDataBuilder.createNote(id: "upd_1", amount: -50.00, description: "Old Name", category: "Food")
        swiftData.seed([original])

        await interactor.saveNote(request: EditNoteScene.SaveNote.Request(
            noteId: "upd_1",
            amount: 99.99,
            description: "New Name",
            category: "Entertainment",
            isPositive: false
        ))

        #expect(presenter.presentSaveResultCalled == true)
        #expect(presenter.lastSaveResponse?.success == true)
        #expect(worker.updateNoteCallCount == 1)
        let updated = swiftData.notes.first(where: { $0.id == "upd_1" })
        #expect(updated?.noteDescription == "New Name")
        #expect(updated?.category == "Entertainment")
        #expect(updated?.amount == -99.99)
    }

    @Test("Save note – non-existent id reports failure")
    func saveNoteNotFound() async {
        let (interactor, presenter, _, _) = makeSUT()

        await interactor.saveNote(request: EditNoteScene.SaveNote.Request(
            noteId: "ghost",
            amount: 10.00,
            description: "Ghost",
            category: "Other",
            isPositive: false
        ))

        #expect(presenter.presentSaveResultCalled == true)
        #expect(presenter.lastSaveResponse?.success == false)
    }

    @Test("Save note – sync status set to pending")
    func saveNoteSyncStatus() async {
        let (interactor, _, _, swiftData) = makeSUT()
        let original = TestDataBuilder.createNote(id: "sync_1", syncStatus: "synced")
        swiftData.seed([original])

        await interactor.saveNote(request: EditNoteScene.SaveNote.Request(
            noteId: "sync_1",
            amount: 1.00,
            description: "Trigger sync",
            category: "Other",
            isPositive: false
        ))

        let updated = swiftData.notes.first(where: { $0.id == "sync_1" })
        #expect(updated?.syncStatus == "pending")
    }

    @Test("Save note – nil presenter does not crash")
    func saveNoteNilPresenter() async {
        let (interactor, _, _, swiftData) = makeSUT()
        interactor.presenter = nil
        swiftData.seed([TestDataBuilder.createNote(id: "x")])

        await interactor.saveNote(request: EditNoteScene.SaveNote.Request(
            noteId: "x",
            amount: 5.00,
            description: "Test",
            category: "Food",
            isPositive: false
        ))
        #expect(true)
    }
}

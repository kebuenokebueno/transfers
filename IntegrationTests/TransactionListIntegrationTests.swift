//
//  NoteListIntegrationTests.swift
//  InigoVIPTests
//
//  Created by Inigo on 29/1/26.
//

import Testing
import Foundation
@testable import InigoVIP

// MARK: - Full VIP Stack Integration Tests

@Suite("NoteList – Full VIP Integration", .tags(.integration))
struct NoteListIntegrationTests {

    // MARK: - Helper – returns every layer wired together

    @MainActor
    private func makeStack() -> (
        interactor: NoteListInteractor,
        presenter: NoteListPresenter,
        vc: MockNoteListViewController,
        worker: MockNoteWorker,
        local: MockSwiftDataService,
        cloud: MockSupabaseService
    ) {
        let local      = MockSwiftDataService()
        let cloud      = MockSupabaseService()
        let worker     = MockNoteWorker(swiftDataService: local, supabaseService: cloud)
        let interactor = NoteListInteractor(noteWorker: worker, swiftDataService: local)
        let presenter  = NoteListPresenter()
        let vc         = MockNoteListViewController()

        interactor.presenter     = presenter
        presenter.viewController = vc

        return (interactor, presenter, vc, worker, local, cloud)
    }

    // MARK: - Fetch → display

    @MainActor
    @Test("Integration: Fetch – notes reach ViewController formatted")
    func integrationFetch() async {
        let (interactor, _, vc, _, local, _) = makeStack()
        local.seed(TestDataBuilder.createMixedNotes())   // 5 notes

        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())

        #expect(vc.displayNotesCalled == true)
        #expect(vc.lastFetchViewModel?.displayedNotes.count == 5)
        #expect(vc.lastFetchViewModel?.displayedNotes.count == 5)

        // Spot-check formatting on a known note
        let grocery = vc.lastFetchViewModel?.displayedNotes.first(where: { $0.description == "Grocery Store" })
        #expect(grocery != nil)
        #expect(grocery?.amount.contains("€") == true)
        #expect(grocery?.isPositive == false)

        let salary = vc.lastFetchViewModel?.displayedNotes.first(where: { $0.description == "Salary" })
        #expect(salary != nil)
        #expect(salary?.isPositive == true)
    }

    @MainActor
    @Test("Integration: Fetch – empty store shows empty list")
    func integrationFetchEmpty() async {
        let (interactor, _, vc, _, _, _) = makeStack()

        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())

        #expect(vc.displayNotesCalled == true)
        #expect(vc.lastFetchViewModel?.displayedNotes.isEmpty == true)
        #expect(vc.lastFetchViewModel?.displayedNotes.count == 0)
    }

    // MARK: - Create → stored → fetch shows it

    @MainActor
    @Test("Integration: Create – note persists and appears on next fetch")
    func integrationCreateThenFetch() async {
        let (interactor, _, vc, _, local, cloud) = makeStack()

        // 1. Create
        await interactor.createNote(request: NoteScene.CreateNote.Request(
            amount: 42.00,
            description: "Integration Lunch",
            category: "Food",
            isIncome: false
        ))

        // VC told success
        #expect(vc.displayCreateResultCalled == true)
        #expect(vc.lastCreateViewModel?.success == true)

        // Landed in both stores
        #expect(local.notes.count == 1)
        #expect(cloud.notes.count == 1)

        // 2. Fetch – should appear in formatted list
        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())

        #expect(vc.lastFetchViewModel?.displayedNotes.count == 1)
        #expect(vc.lastFetchViewModel?.displayedNotes.first?.description == "Integration Lunch")
        #expect(vc.lastFetchViewModel?.displayedNotes.first?.amount.contains("42") == true)
    }

    @MainActor
    @Test("Integration: Create income – amount stays positive through stack")
    func integrationCreateIncome() async {
        let (interactor, _, vc, _, _, _) = makeStack()

        await interactor.createNote(request: NoteScene.CreateNote.Request(
            amount: 3000.00,
            description: "Bonus",
            category: "Income",
            isIncome: true
        ))

        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())

        let displayed = vc.lastFetchViewModel?.displayedNotes.first
        #expect(displayed != nil)
        #expect(displayed?.isPositive == true)
        #expect(displayed?.amount.contains("3") == true)
        #expect(displayed?.amount.contains("000") == true)
    }

    // MARK: - Update → fetch shows updated data

    @MainActor
    @Test("Integration: Update – changes visible on next fetch")
    func integrationUpdateThenFetch() async {
        let (interactor, _, vc, _, local, cloud) = makeStack()

        // Seed
        let original = TestDataBuilder.createNote(id: "int_u1", amount: -10.0, description: "Before", category: "Food")
        local.seed([original])
        cloud.notes  = [original]

        // Update
        await interactor.updateNote(request: NoteScene.UpdateNote.Request(
            noteId: "int_u1",
            amount: 55.55,
            description: "After",
            category: "Entertainment"
        ))

        #expect(vc.displayUpdateResultCalled == true)
        #expect(vc.lastUpdateViewModel?.success == true)

        // Fetch – formatted list reflects the change
        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())

        let displayed = vc.lastFetchViewModel?.displayedNotes.first
        #expect(displayed != nil)
        #expect(displayed?.description == "After")
        #expect(displayed?.category == "Entertainment")
        #expect(displayed?.amount.contains("55") == true)
    }

    @MainActor
    @Test("Integration: Update non-existent – failure propagates cleanly")
    func integrationUpdateMissing() async {
        let (interactor, _, vc, _, _, _) = makeStack()

        await interactor.updateNote(request: NoteScene.UpdateNote.Request(
            noteId: "no_such_id",
            amount: 1.0,
            description: "Ghost",
            category: "Other"
        ))

        #expect(vc.displayUpdateResultCalled == true)
        #expect(vc.lastUpdateViewModel?.success == false)
    }

    // MARK: - Delete → fetch confirms removal

    @MainActor
    @Test("Integration: Delete – note gone from stores and next fetch")
    func integrationDeleteThenFetch() async {
        let (interactor, _, vc, _, local, cloud) = makeStack()

        let notes = TestDataBuilder.createMixedNotes()
        local.seed(notes)
        cloud.notes = notes

        // Delete note with id "2" (Electric Bill)
        await interactor.deleteNote(request: NoteScene.DeleteNote.Request(noteId: "2"))

        #expect(vc.displayDeleteResultCalled == true)
        #expect(vc.lastDeleteViewModel?.success == true)

        // Gone from both stores
        #expect(local.notes.contains(where: { $0.id == "2" }) == false)
        #expect(cloud.notes.contains(where: { $0.id == "2" }) == false)

        // Fetch – formatted list no longer contains it
        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())

        #expect(vc.lastFetchViewModel?.displayedNotes.count == 4)
        #expect(vc.lastFetchViewModel?.displayedNotes.contains(where: { $0.id == "2" }) == false)
    }

    @MainActor
    @Test("Integration: Delete all – list becomes empty")
    func integrationDeleteAll() async {
        let (interactor, _, vc, _, local, _) = makeStack()

        let notes = TestDataBuilder.createMixedNotes()
        local.seed(notes)

        for note in notes {
            await interactor.deleteNote(request: NoteScene.DeleteNote.Request(noteId: note.id))
        }

        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())

        #expect(vc.lastFetchViewModel?.displayedNotes.isEmpty == true)
        #expect(vc.lastFetchViewModel?.displayedNotes.count == 0)
    }

    // MARK: - Full lifecycle: create → fetch → update → fetch → delete → fetch

    @MainActor
    @Test("Integration: Full CRUD lifecycle end-to-end")
    func integrationFullLifecycle() async {
        let (interactor, _, vc, _, local, _) = makeStack()

        // ── CREATE ──
        await interactor.createNote(request: NoteScene.CreateNote.Request(
            amount: 25.00,
            description: "Lifecycle Note",
            category: "Food",
            isIncome: false
        ))
        #expect(local.notes.count == 1)
        let createdId = local.notes.first!.id

        // ── FETCH ──
        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())
        #expect(vc.lastFetchViewModel?.displayedNotes.count == 1)
        #expect(vc.lastFetchViewModel?.displayedNotes.first?.description == "Lifecycle Note")

        // ── UPDATE ──
        await interactor.updateNote(request: NoteScene.UpdateNote.Request(
            noteId: createdId,
            amount: 50.00,
            description: "Lifecycle Note – Updated",
            category: "Entertainment"
        ))
        #expect(vc.lastUpdateViewModel?.success == true)

        // ── FETCH after update ──
        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())
        #expect(vc.lastFetchViewModel?.displayedNotes.first?.description == "Lifecycle Note – Updated")
        #expect(vc.lastFetchViewModel?.displayedNotes.first?.category == "Entertainment")

        // ── DELETE ──
        await interactor.deleteNote(request: NoteScene.DeleteNote.Request(noteId: createdId))
        #expect(vc.lastDeleteViewModel?.success == true)
        #expect(local.notes.isEmpty)

        // ── FETCH after delete ──
        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())
        #expect(vc.lastFetchViewModel?.displayedNotes.isEmpty == true)
    }

    // MARK: - Cloud failure paths – local still works

    @MainActor
    @Test("Integration: Cloud down – create still persists locally")
    func integrationCloudDownCreate() async {
        let (interactor, _, vc, _, local, cloud) = makeStack()
        cloud.shouldFail = true

        await interactor.createNote(request: NoteScene.CreateNote.Request(
            amount: 10.0,
            description: "Offline Note",
            category: "Other",
            isIncome: false
        ))

        // Persisted locally despite cloud failure
        #expect(local.notes.count == 1)
        #expect(vc.displayCreateResultCalled == true)

        // Fetch still surfaces it
        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())
        #expect(vc.lastFetchViewModel?.displayedNotes.count == 1)
        #expect(vc.lastFetchViewModel?.displayedNotes.first?.description == "Offline Note")
    }

    @MainActor
    @Test("Integration: Cloud down – update still persists locally")
    func integrationCloudDownUpdate() async {
        let (interactor, _, vc, _, local, cloud) = makeStack()

        let original = TestDataBuilder.createNote(id: "offline_u", description: "Original")
        local.seed([original])
        cloud.shouldFail = true   // cloud goes down after seed

        await interactor.updateNote(request: NoteScene.UpdateNote.Request(
            noteId: "offline_u",
            amount: 77.0,
            description: "Offline Update",
            category: "Food"
        ))

        // Local reflects the change
        #expect(local.notes.first?.noteDescription == "Offline Update")

        // Fetch confirms it comes through formatted
        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())
        #expect(vc.lastFetchViewModel?.displayedNotes.first?.description == "Offline Update")
    }

    @MainActor
    @Test("Integration: Cloud down – delete still removes locally")
    func integrationCloudDownDelete() async {
        let (interactor, _, vc, _, local, cloud) = makeStack()

        local.seed([TestDataBuilder.createNote(id: "offline_d")])
        cloud.shouldFail = true

        await interactor.deleteNote(request: NoteScene.DeleteNote.Request(noteId: "offline_d"))

        #expect(local.notes.isEmpty)

        await interactor.fetchNotes(request: NoteScene.FetchNotes.Request())
        #expect(vc.lastFetchViewModel?.displayedNotes.isEmpty == true)
    }

    // MARK: - Fetch single note through full stack

    @MainActor
    @Test("Integration: Fetch single note – formatted detail reaches VC")
    func integrationFetchSingleNote() async {
        let (interactor, _, vc, _, local, _) = makeStack()

        local.seed(TestDataBuilder.createMixedNotes())

        await interactor.fetchNote(request: NoteScene.FetchNote.Request(noteId: "4"))

        #expect(vc.displayNoteCalled == true)
        #expect(vc.lastNoteViewModel?.displayedNote?.id == "4")
        #expect(vc.lastNoteViewModel?.displayedNote?.description == "Gas Station")
        #expect(vc.lastNoteViewModel?.displayedNote?.category == "Transport")
        #expect(vc.lastNoteViewModel?.displayedNote?.amount.contains("30") == true)
        #expect(vc.lastNoteViewModel?.displayedNote?.isPositive == false)
    }
}

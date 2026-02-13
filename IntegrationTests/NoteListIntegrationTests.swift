//
//  NoteListIntegrationTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@Suite("NoteList - Full VIP Integration", .tags(.integration))
struct NoteListIntegrationTests {

    @MainActor
    private func makeStack() -> (
        interactor: NoteListInteractor,
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
        return (interactor, vc, worker, local, cloud)
    }

    // MARK: - Fetch

    @MainActor @Test("Integration: Fetch - notes reach ViewController formatted")
    func integrationFetch() async {
        let (interactor, vc, _, local, _) = makeStack()
        local.seed(TestDataBuilder.createMixedNotes())
        await interactor.fetchNotes()
        #expect(vc.displayNotesCalled == true)
        #expect(vc.lastFetchViewModel?.displayedNotes.count == 5)
        let grocery = vc.lastFetchViewModel?.displayedNotes.first(where: { $0.description == "Grocery Store" })
        #expect(grocery?.isPositive == false)
        let salary = vc.lastFetchViewModel?.displayedNotes.first(where: { $0.description == "Salary" })
        #expect(salary?.isPositive == true)
    }

    @MainActor @Test("Integration: Fetch - empty store shows empty list")
    func integrationFetchEmpty() async {
        let (interactor, vc, _, _, _) = makeStack()
        await interactor.fetchNotes()
        #expect(vc.displayNotesCalled == true)
        #expect(vc.lastFetchViewModel?.displayedNotes.isEmpty == true)
    }

    // MARK: - Delete then fetch

    @MainActor @Test("Integration: Delete - note gone from stores and next fetch")
    func integrationDeleteThenFetch() async {
        let (interactor, vc, _, local, cloud) = makeStack()
        let notes = TestDataBuilder.createMixedNotes()
        local.seed(notes)
        cloud.notes = notes
        await interactor.deleteNote(request: NoteScene.DeleteNote.Request(noteId: "2"))
        #expect(vc.displayDeleteResultCalled == true)
        #expect(vc.lastDeleteViewModel?.success == true)
        #expect(local.notes.contains(where: { $0.id == "2" }) == false)
        #expect(cloud.notes.contains(where: { $0.id == "2" }) == false)
        await interactor.fetchNotes()
        #expect(vc.lastFetchViewModel?.displayedNotes.count == 4)
        #expect(vc.lastFetchViewModel?.displayedNotes.contains(where: { $0.id == "2" }) == false)
    }

    @MainActor @Test("Integration: Delete all - list becomes empty")
    func integrationDeleteAll() async {
        let (interactor, vc, _, local, _) = makeStack()
        let notes = TestDataBuilder.createMixedNotes()
        local.seed(notes)
        for note in notes {
            await interactor.deleteNote(request: NoteScene.DeleteNote.Request(noteId: note.id))
        }
        await interactor.fetchNotes()
        #expect(vc.lastFetchViewModel?.displayedNotes.isEmpty == true)
    }

    // MARK: - Cloud failure paths

    @MainActor @Test("Integration: Cloud down - delete still removes locally")
    func integrationCloudDownDelete() async {
        let (interactor, vc, _, local, cloud) = makeStack()
        local.seed([TestDataBuilder.createNote(id: "offline_d")])
        cloud.shouldFail = true
        await interactor.deleteNote(request: NoteScene.DeleteNote.Request(noteId: "offline_d"))
        #expect(local.notes.isEmpty)
        await interactor.fetchNotes()
        #expect(vc.lastFetchViewModel?.displayedNotes.isEmpty == true)
    }
}

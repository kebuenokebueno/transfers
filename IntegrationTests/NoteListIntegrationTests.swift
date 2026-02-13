//
//  NoteListIntegrationTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@Suite("NoteList - Full MVVM Integration", .tags(.integration))
struct NoteListIntegrationTests {

    @MainActor
    private func makeStack() -> (
        viewModel: NoteListViewModel,
        worker: MockNoteWorker,
        local: MockSwiftDataService,
        cloud: MockSupabaseService,
        router: MockRouter
    ) {
        let local  = MockSwiftDataService()
        let cloud  = MockSupabaseService()
        let worker = MockNoteWorker(swiftDataService: local, supabaseService: cloud)
        let router = MockRouter()
        let viewModel = NoteListViewModel(
            noteWorker: worker,
            swiftDataService: local,
            router: router
        )
        return (viewModel, worker, local, cloud, router)
    }

    // MARK: - Fetch

    @MainActor @Test("Integration: Fetch - notes reach ViewModel formatted")
    func integrationFetch() async throws {
        let (viewModel, _, local, _, _) = makeStack()
        local.seed(TestDataBuilder.createMixedNotes())
        
        viewModel.loadNotes()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.displayedNotes.count == 5)
        
        let grocery = viewModel.displayedNotes.first(where: { $0.description == "Grocery Store" })
        #expect(grocery?.isPositive == false)
        
        let salary = viewModel.displayedNotes.first(where: { $0.description == "Salary" })
        #expect(salary?.isPositive == true)
    }

    @MainActor @Test("Integration: Fetch - empty store shows empty list")
    func integrationFetchEmpty() async throws {
        let (viewModel, _, _, _, _) = makeStack()
        
        viewModel.loadNotes()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.displayedNotes.isEmpty == true)
    }

    // MARK: - Delete then fetch

    @MainActor @Test("Integration: Delete - note gone from stores and next fetch")
    func integrationDeleteThenFetch() async throws {
        let (viewModel, _, local, cloud, _) = makeStack()
        let notes = TestDataBuilder.createMixedNotes()
        local.seed(notes)
        cloud.notes = notes
        
        viewModel.deleteNote(noteId: "2")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(local.notes.contains(where: { $0.id == "2" }) == false)
        #expect(cloud.notes.contains(where: { $0.id == "2" }) == false)
        
        // After deletion, the list should be refreshed automatically
        #expect(viewModel.displayedNotes.count == 4)
        #expect(viewModel.displayedNotes.contains(where: { $0.id == "2" }) == false)
    }

    @MainActor @Test("Integration: Delete all - list becomes empty")
    func integrationDeleteAll() async throws {
        let (viewModel, _, local, _, _) = makeStack()
        let notes = TestDataBuilder.createMixedNotes()
        local.seed(notes)
        
        for note in notes {
            viewModel.deleteNote(noteId: note.id)
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(viewModel.displayedNotes.isEmpty == true)
    }

    // MARK: - Cloud failure paths

    @MainActor @Test("Integration: Cloud down - delete still removes locally")
    func integrationCloudDownDelete() async throws {
        let (viewModel, _, local, cloud, _) = makeStack()
        local.seed([TestDataBuilder.createNote(id: "offline_d")])
        cloud.shouldFail = true
        
        viewModel.deleteNote(noteId: "offline_d")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(local.notes.isEmpty)
        #expect(viewModel.displayedNotes.isEmpty == true)
    }
    
    // MARK: - Navigation
    
    @MainActor @Test("Integration: Navigation - select note navigates to detail")
    func integrationNavigateToDetail() async throws {
        let (viewModel, _, local, _, router) = makeStack()
        local.seed(TestDataBuilder.createMixedNotes())
        
        viewModel.didSelectNote(noteId: "3")
        
        #expect(router.navigateToCallCount == 1)
        if case .noteDetail(let id) = router.lastNavigatedRoute {
            #expect(id == "3")
        } else {
            Issue.record("Expected noteDetail route")
        }
    }
    
    @MainActor @Test("Integration: Navigation - add note presents sheet")
    func integrationPresentAddNote() async throws {
        let (viewModel, _, _, _, router) = makeStack()
        
        viewModel.didTapAddNote()
        
        #expect(router.presentSheetCallCount == 1)
        #expect(router.lastPresentedSheet == .addNote)
    }
}

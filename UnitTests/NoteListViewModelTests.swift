//
//  NoteListViewModelTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("NoteList ViewModel Tests", .tags(.unit, .viewModel))
struct NoteListViewModelTests {

    private func makeSUT() -> (
        viewModel: NoteListViewModel,
        worker: MockNoteWorker,
        swiftData: MockSwiftDataService,
        router: MockRouter
    ) {
        let swiftData = MockSwiftDataService()
        let supabase = MockSupabaseService()
        let worker = MockNoteWorker(swiftDataService: swiftData, supabaseService: supabase)
        let router = MockRouter()
        let viewModel = NoteListViewModel(
            noteWorker: worker,
            swiftDataService: swiftData,
            router: router
        )
        return (viewModel, worker, swiftData, router)
    }

    // MARK: - Fetch Notes

    @Test("Fetch notes - returns all notes formatted")
    func fetchNotesSuccess() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedNotes())
        
        viewModel.loadNotes()
        try await Task.sleep(nanoseconds: 100_000_000) // Wait for async task
        
        #expect(viewModel.displayedNotes.count == 5)
        #expect(viewModel.isLoading == false)
    }

    @Test("Fetch notes - empty SwiftData returns empty array")
    func fetchNotesEmpty() async throws {
        let (viewModel, _, _, _) = makeSUT()
        
        viewModel.loadNotes()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.displayedNotes.isEmpty)
        #expect(viewModel.isLoading == false)
    }

    @Test("Fetch notes - formats amounts correctly")
    func fetchNotesFormatsAmounts() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed([
            TestDataBuilder.createNote(id: "1", amount: 100.50),
            TestDataBuilder.createNote(id: "2", amount: -50.25)
        ])
        
        viewModel.loadNotes()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        let positiveNote = viewModel.displayedNotes.first { $0.id == "1" }
        let negativeNote = viewModel.displayedNotes.first { $0.id == "2" }
        
        #expect(positiveNote?.amount == "+€100.50")
        #expect(negativeNote?.amount == "-€50.25")
    }

    @Test("Fetch notes - large dataset 1000 notes")
    func fetchNotesLargeDataset() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed(TestDataBuilder.createNotes(count: 1000))
        
        viewModel.loadNotes()
        try await Task.sleep(nanoseconds: 200_000_000)
        
        #expect(viewModel.displayedNotes.count == 1000)
    }

    // MARK: - Delete Note

    @Test("Delete note - removes note and refreshes list")
    func deleteNoteSuccess() async throws {
        let (viewModel, worker, swiftData, _) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedNotes())
        
        viewModel.deleteNote(noteId: "3")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(worker.deleteNoteCallCount == 1)
        #expect(swiftData.notes.count == 4)
        #expect(swiftData.notes.contains(where: { $0.id == "3" }) == false)
    }

    // MARK: - Navigation

    @Test("Select note - navigates to detail")
    func selectNoteNavigates() {
        let (viewModel, _, _, router) = makeSUT()
        
        viewModel.didSelectNote(noteId: "test_123")
        
        #expect(router.navigateToCallCount == 1)
        if case .noteDetail(let id) = router.lastNavigatedRoute {
            #expect(id == "test_123")
        } else {
            Issue.record("Expected noteDetail route")
        }
    }

    @Test("Add note - presents sheet")
    func addNotePresentsSheet() {
        let (viewModel, _, _, router) = makeSUT()
        
        viewModel.didTapAddNote()
        
        #expect(router.presentSheetCallCount == 1)
        #expect(router.lastPresentedSheet == .addNote)
    }

    @Test("Edit note - navigates to edit")
    func editNoteNavigates() {
        let (viewModel, _, _, router) = makeSUT()
        
        viewModel.didTapEditNote(noteId: "test_456")
        
        #expect(router.navigateToCallCount == 1)
        if case .editNote(let id) = router.lastNavigatedRoute {
            #expect(id == "test_456")
        } else {
            Issue.record("Expected editNote route")
        }
    }

    // MARK: - Loading State

    @Test("Loading state - set to true when loading starts")
    func loadingStateTrue() {
        let (viewModel, _, _, _) = makeSUT()
        
        viewModel.loadNotes()
        
        #expect(viewModel.isLoading == true)
    }
}

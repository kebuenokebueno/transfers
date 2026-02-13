//
//  NoteDetailViewModelTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("NoteDetail ViewModel Tests", .tags(.unit, .viewModel))
struct NoteDetailViewModelTests {

    private func makeSUT() -> (
        viewModel: NoteDetailViewModel,
        worker: MockNoteWorker,
        swiftData: MockSwiftDataService,
        router: MockRouter
    ) {
        let swiftData = MockSwiftDataService()
        let supabase = MockSupabaseService()
        let worker = MockNoteWorker(swiftDataService: swiftData, supabaseService: supabase)
        let router = MockRouter()
        let viewModel = NoteDetailViewModel(
            noteWorker: worker,
            swiftDataService: swiftData,
            router: router
        )
        return (viewModel, worker, swiftData, router)
    }

    // MARK: - Load Note

    @Test("Load note - displays formatted note")
    func loadNoteSuccess() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed([TestDataBuilder.createNote(
            id: "test_1",
            amount: 150.75,
            description: "Test Note",
            category: "Income"
        )])
        
        viewModel.loadNote(noteId: "test_1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.note != nil)
        #expect(viewModel.note?.id == "test_1")
        #expect(viewModel.note?.amount == "+€150.75")
        #expect(viewModel.note?.description == "Test Note")
        #expect(viewModel.note?.category == "Income")
    }

    @Test("Load note - not found returns nil")
    func loadNoteNotFound() async throws {
        let (viewModel, _, _, _) = makeSUT()
        
        viewModel.loadNote(noteId: "nonexistent")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.note == nil)
    }

    @Test("Load note - formats negative amount correctly")
    func loadNoteNegativeAmount() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed([TestDataBuilder.createNote(id: "1", amount: -75.25)])
        
        viewModel.loadNote(noteId: "1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.note?.amount == "-€75.25")
        #expect(viewModel.note?.isPositive == false)
    }

    // MARK: - Delete Note

    @Test("Delete note - removes and navigates back")
    func deleteNoteSuccess() async throws {
        let (viewModel, worker, swiftData, router) = makeSUT()
        swiftData.seed([TestDataBuilder.createNote(id: "test_1")])
        
        viewModel.deleteNote(noteId: "test_1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(worker.deleteNoteCallCount == 1)
        #expect(swiftData.notes.isEmpty)
        #expect(router.navigateBackCallCount == 1)
    }

    // MARK: - Navigation

    @Test("Edit note - navigates to edit screen")
    func editNoteNavigates() {
        let (viewModel, _, _, router) = makeSUT()
        
        viewModel.didTapEdit(noteId: "test_123")
        
        #expect(router.navigateToCallCount == 1)
        if case .editNote(let id) = router.lastNavigatedRoute {
            #expect(id == "test_123")
        } else {
            Issue.record("Expected editNote route")
        }
    }
}

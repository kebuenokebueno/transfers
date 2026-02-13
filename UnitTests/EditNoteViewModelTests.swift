//
//  EditNoteViewModelTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("EditNote ViewModel Tests", .tags(.unit, .viewModel))
struct EditNoteViewModelTests {

    private func makeSUT() -> (
        viewModel: EditNoteViewModel,
        worker: MockNoteWorker,
        swiftData: MockSwiftDataService,
        router: MockRouter
    ) {
        let swiftData = MockSwiftDataService()
        let supabase = MockSupabaseService()
        let worker = MockNoteWorker(swiftDataService: swiftData, supabaseService: supabase)
        let router = MockRouter()
        let viewModel = EditNoteViewModel(
            noteWorker: worker,
            swiftDataService: swiftData,
            router: router
        )
        return (viewModel, worker, swiftData, router)
    }

    // MARK: - Load Note

    @Test("Load note - populates form fields")
    func loadNoteSuccess() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed([TestDataBuilder.createNote(
            id: "test_1",
            amount: -75.50,
            description: "Test Note",
            category: "Food"
        )])
        
        viewModel.loadNote(noteId: "test_1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.amount == "75.5")
        #expect(viewModel.description == "Test Note")
        #expect(viewModel.category == "Food")
        #expect(viewModel.isPositive == false)
        #expect(viewModel.isLoading == false)
    }

    @Test("Load note - positive amount sets isPositive true")
    func loadNotePositiveAmount() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed([TestDataBuilder.createNote(id: "1", amount: 100.0)])
        
        viewModel.loadNote(noteId: "1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.isPositive == true)
    }

    @Test("Load note - not found clears fields")
    func loadNoteNotFound() async throws {
        let (viewModel, _, _, _) = makeSUT()
        
        viewModel.loadNote(noteId: "nonexistent")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.amount == "")
        #expect(viewModel.description == "")
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Save Note

    @Test("Save note - updates note and navigates back")
    func saveNoteSuccess() async throws {
        let (viewModel, worker, swiftData, router) = makeSUT()
        swiftData.seed([TestDataBuilder.createNote(id: "test_1", amount: -50.0)])
        
        viewModel.amount = "75"
        viewModel.description = "Updated"
        viewModel.category = "Transport"
        viewModel.isPositive = false
        
        viewModel.saveNote(noteId: "test_1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(worker.updateNoteCallCount == 1)
        #expect(swiftData.notes.first?.amount == -75.0)
        #expect(swiftData.notes.first?.noteDescription == "Updated")
        #expect(router.navigateBackCallCount == 1)
    }

    @Test("Save note - positive amount stored correctly")
    func saveNotePositiveAmount() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed([TestDataBuilder.createNote(id: "1")])
        
        viewModel.amount = "100"
        viewModel.description = "Income"
        viewModel.category = "Income"
        viewModel.isPositive = true
        
        viewModel.saveNote(noteId: "1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(swiftData.notes.first?.amount == 100.0)
    }

    @Test("Save note - not found shows error")
    func saveNoteNotFound() async throws {
        let (viewModel, _, _, router) = makeSUT()
        
        viewModel.amount = "50"
        viewModel.description = "Test"
        viewModel.category = "Food"
        
        viewModel.saveNote(noteId: "nonexistent")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.errorMessage != nil)
        #expect(router.navigateBackCallCount == 0)
    }

    // MARK: - Loading State

    @Test("Initial state - isLoading true")
    func initialLoadingState() {
        let (viewModel, _, _, _) = makeSUT()
        #expect(viewModel.isLoading == true)
    }

    @Test("Save state - isSaving true during save")
    func savingState() {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed([TestDataBuilder.createNote(id: "1")])
        viewModel.amount = "50"
        viewModel.description = "Test"
        viewModel.category = "Food"
        
        viewModel.saveNote(noteId: "1")
        
        #expect(viewModel.isSaving == true)
    }
}

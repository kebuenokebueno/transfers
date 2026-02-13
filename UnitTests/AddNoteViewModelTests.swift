//
//  AddNoteViewModelTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("AddNote ViewModel Tests", .tags(.unit, .viewModel))
struct AddNoteViewModelTests {

    private func makeSUT() -> (
        viewModel: AddNoteViewModel,
        worker: MockNoteWorker,
        swiftData: MockSwiftDataService,
        router: MockRouter
    ) {
        let swiftData = MockSwiftDataService()
        let supabase = MockSupabaseService()
        let worker = MockNoteWorker(swiftDataService: swiftData, supabaseService: supabase)
        let router = MockRouter()
        let viewModel = AddNoteViewModel(noteWorker: worker, router: router)
        return (viewModel, worker, swiftData, router)
    }

    // MARK: - Save Note

    @Test("Save expense - creates note with negative amount")
    func saveExpense() async throws {
        let (viewModel, worker, swiftData, router) = makeSUT()
        
        viewModel.saveNote(amount: 50.0, description: "Test", category: "Food", isIncome: false)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(worker.createNoteCallCount == 1)
        #expect(swiftData.notes.first?.amount == -50.0)
        #expect(router.dismissCallCount == 1)
    }

    @Test("Save income - creates note with positive amount")
    func saveIncome() async throws {
        let (viewModel, worker, swiftData, router) = makeSUT()
        
        viewModel.saveNote(amount: 100.0, description: "Salary", category: "Income", isIncome: true)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(worker.createNoteCallCount == 1)
        #expect(swiftData.notes.first?.amount == 100.0)
        #expect(router.dismissCallCount == 1)
    }

    @Test("Save note - sets isSaving during save")
    func isSavingState() {
        let (viewModel, _, _, _) = makeSUT()
        
        viewModel.saveNote(amount: 50.0, description: "Test", category: "Food", isIncome: false)
        
        #expect(viewModel.isSaving == true)
    }

    @Test("Save note - stores correct properties")
    func saveNoteProperties() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        
        viewModel.saveNote(amount: 75.50, description: "Groceries", category: "Food", isIncome: false)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        let savedNote = swiftData.notes.first
        #expect(savedNote?.noteDescription == "Groceries")
        #expect(savedNote?.category == "Food")
        #expect(savedNote?.syncStatus == "pending")
    }

    // MARK: - Dismiss

    @Test("Dismiss - calls router dismiss")
    func dismiss() {
        let (viewModel, _, _, router) = makeSUT()
        
        viewModel.dismiss()
        
        #expect(router.dismissCallCount == 1)
    }
}

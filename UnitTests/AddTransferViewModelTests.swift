//
//  AddTransferViewModelTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("AddTransfer ViewModel Tests", .tags(.unit, .viewModel))
struct AddTransferViewModelTests {

    private func makeSUT() -> (
        viewModel: AddTransferViewModel,
        worker: MockTransferWorker,
        swiftData: MockSwiftDataService,
        router: MockRouter
    ) {
        let swiftData = MockSwiftDataService()
        let supabase = MockSupabaseService()
        let worker = MockTransferWorker(swiftDataService: swiftData, supabaseService: supabase)
        let router = MockRouter()
        let viewModel = AddTransferViewModel(transferWorker: worker, router: router)
        return (viewModel, worker, swiftData, router)
    }

    // MARK: - Save Transfer

    @Test("Save expense - creates transfer with negative amount")
    func saveExpense() async throws {
        let (viewModel, worker, swiftData, router) = makeSUT()
        
        viewModel.saveTransfer(amount: 50.0, description: "Test", category: "Food", isIncome: false)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(worker.createTransferCallCount == 1)
        #expect(swiftData.transfers.first?.amount == -50.0)
        #expect(router.dismissCallCount == 1)
    }

    @Test("Save income - creates transfer with positive amount")
    func saveIncome() async throws {
        let (viewModel, worker, swiftData, router) = makeSUT()
        
        viewModel.saveTransfer(amount: 100.0, description: "Salary", category: "Income", isIncome: true)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(worker.createTransferCallCount == 1)
        #expect(swiftData.transfers.first?.amount == 100.0)
        #expect(router.dismissCallCount == 1)
    }

    @Test("Save transfer - sets isSaving during save")
    func isSavingState() {
        let (viewModel, _, _, _) = makeSUT()
        
        viewModel.saveTransfer(amount: 50.0, description: "Test", category: "Food", isIncome: false)
        
        #expect(viewModel.isSaving == true)
    }

    @Test("Save transfer - stores correct properties")
    func saveTransferProperties() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        
        viewModel.saveTransfer(amount: 75.50, description: "Groceries", category: "Food", isIncome: false)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        let savedTransfer = swiftData.transfers.first
        #expect(savedTransfer?.transferDescription == "Groceries")
        #expect(savedTransfer?.category == "Food")
        #expect(savedTransfer?.syncStatus == "pending")
    }

    // MARK: - Dismiss

    @Test("Dismiss - calls router dismiss")
    func dismiss() {
        let (viewModel, _, _, router) = makeSUT()
        
        viewModel.dismiss()
        
        #expect(router.dismissCallCount == 1)
    }
}

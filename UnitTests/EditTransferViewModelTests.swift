//
//  EditTransferViewModelTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("EditTransfer ViewModel Tests", .tags(.unit, .viewModel))
struct EditTransferViewModelTests {

    private func makeSUT() -> (
        viewModel: EditTransferViewModel,
        worker: MockTransferWorker,
        swiftData: MockSwiftDataService,
        router: MockRouter
    ) {
        let swiftData = MockSwiftDataService()
        let supabase = MockSupabaseService()
        let worker = MockTransferWorker(swiftDataService: swiftData, supabaseService: supabase)
        let router = MockRouter()
        let viewModel = EditTransferViewModel(
            transferWorker: worker,
            swiftDataService: swiftData,
            router: router
        )
        return (viewModel, worker, swiftData, router)
    }

    // MARK: - Load Transfer

    @Test("Load Transfer - populates form fields")
    func loadTransferSuccess() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed([TestDataBuilder.createTransfer(
            id: "test_1",
            amount: -75.50,
            description: "Test Transfer",
            category: "Food"
        )])
        
        viewModel.loadTransfer(transferId: "test_1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.amount == "75.5")
        #expect(viewModel.description == "Test Transfer")
        #expect(viewModel.category == "Food")
        #expect(viewModel.isPositive == false)
        #expect(viewModel.isLoading == false)
    }

    @Test("Load Transfer - positive amount sets isPositive true")
    func loadTransferPositiveAmount() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed([TestDataBuilder.createTransfer(id: "1", amount: 100.0)])
        
        viewModel.loadTransfer(transferId: "1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.isPositive == true)
    }

    @Test("Load Transfer - not found clears fields")
    func loadTransferNotFound() async throws {
        let (viewModel, _, _, _) = makeSUT()
        
        viewModel.loadTransfer(transferId: "nonexistent")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.amount == "")
        #expect(viewModel.description == "")
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Save Transfer

    @Test("Save Transfer - updates Transfer and navigates back")
    func saveTransferSuccess() async throws {
        let (viewModel, worker, swiftData, router) = makeSUT()
        swiftData.seed([TestDataBuilder.createTransfer(id: "test_1", amount: -50.0)])
        
        viewModel.amount = "75"
        viewModel.description = "Updated"
        viewModel.category = "Transport"
        viewModel.isPositive = false
        
        viewModel.saveTransfer(transferId: "test_1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(worker.updateTransferCallCount == 1)
        #expect(swiftData.transfers.first?.amount == -75.0)
        #expect(swiftData.transfers.first?.transferDescription == "Updated")
        #expect(router.navigateBackCallCount == 1)
    }

    @Test("Save Transfer - positive amount stored correctly")
    func saveTransferPositiveAmount() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed([TestDataBuilder.createTransfer(id: "1")])
        
        viewModel.amount = "100"
        viewModel.description = "Income"
        viewModel.category = "Income"
        viewModel.isPositive = true
        
        viewModel.saveTransfer(transferId: "1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(swiftData.transfers.first?.amount == 100.0)
    }

    @Test("Save Transfer - not found shows error")
    func saveTransferNotFound() async throws {
        let (viewModel, _, _, router) = makeSUT()
        
        viewModel.amount = "50"
        viewModel.description = "Test"
        viewModel.category = "Food"
        
        viewModel.saveTransfer(transferId: "nonexistent")
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
        swiftData.seed([TestDataBuilder.createTransfer(id: "1")])
        viewModel.amount = "50"
        viewModel.description = "Test"
        viewModel.category = "Food"
        
        viewModel.saveTransfer(transferId: "1")
        
        #expect(viewModel.isSaving == true)
    }
}

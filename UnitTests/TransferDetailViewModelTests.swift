//
//  TransferDetailViewModelTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("TransferDetail ViewModel Tests", .tags(.unit, .viewModel))
struct TransferDetailViewModelTests {

    private func makeSUT() -> (
        viewModel: TransferDetailViewModel,
        worker: MockTransferWorker,
        swiftData: MockSwiftDataService,
        router: MockRouter
    ) {
        let swiftData = MockSwiftDataService()
        let supabase = MockSupabaseService()
        let worker = MockTransferWorker(swiftDataService: swiftData, supabaseService: supabase)
        let router = MockRouter()
        let viewModel = TransferDetailViewModel(
            transferWorker: worker,
            swiftDataService: swiftData,
            router: router
        )
        return (viewModel, worker, swiftData, router)
    }

    // MARK: - Load Transfer

    @Test("Load transfer - displays formatted transfer")
    func loadTransferSuccess() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed([TestDataBuilder.createTransfer(
            id: "test_1",
            amount: 150.75,
            description: "Test Transfer",
            category: "Income"
        )])
        
        viewModel.loadTransfer(transferId: "test_1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.transfer != nil)
        #expect(viewModel.transfer?.id == "test_1")
        #expect(viewModel.transfer?.amount == "+€150.75")
        #expect(viewModel.transfer?.description == "Test Transfer")
        #expect(viewModel.transfer?.category == "Income")
    }

    @Test("Load transfer - not found returns nil")
    func loadTransferNotFound() async throws {
        let (viewModel, _, _, _) = makeSUT()
        
        viewModel.loadTransfer(transferId: "nonexistent")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.transfer == nil)
    }

    @Test("Load transfer - formats negative amount correctly")
    func loadTransferNegativeAmount() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed([TestDataBuilder.createTransfer(id: "1", amount: -75.25)])
        
        viewModel.loadTransfer(transferId: "1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.transfer?.amount == "-€75.25")
        #expect(viewModel.transfer?.isPositive == false)
    }

    // MARK: - Delete Transfer

    @Test("Delete transfer - removes and navigates back")
    func deleteTransferSuccess() async throws {
        let (viewModel, worker, swiftData, router) = makeSUT()
        swiftData.seed([TestDataBuilder.createTransfer(id: "test_1")])
        
        viewModel.deleteTransfer(transferId: "test_1")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(worker.deleteTransferCallCount == 1)
        #expect(swiftData.transfers.isEmpty)
        #expect(router.navigateBackCallCount == 1)
    }

    // MARK: - Navigation

    @Test("Edit transfer - navigates to edit screen")
    func editTransferNavigates() {
        let (viewModel, _, _, router) = makeSUT()
        
        viewModel.didTapEdit(transferId: "test_123")
        
        #expect(router.navigateToCallCount == 1)
        if case .editTransfer(let id) = router.lastNavigatedRoute {
            #expect(id == "test_123")
        } else {
            Issue.record("Expected editTransfer route")
        }
    }
}

//
//  TransferListViewModelTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("TransferList ViewModel Tests", .tags(.unit, .viewModel))
struct TransferListViewModelTests {

    private func makeSUT() -> (
        viewModel: TransferListViewModel,
        worker: MockTransferWorker,
        swiftData: MockSwiftDataService,
        router: MockRouter
    ) {
        let swiftData = MockSwiftDataService()
        let supabase = MockSupabaseService()
        let worker = MockTransferWorker(swiftDataService: swiftData, supabaseService: supabase)
        let router = MockRouter()
        let viewModel = TransferListViewModel(
            transferWorker: worker,
            swiftDataService: swiftData,
            router: router
        )
        return (viewModel, worker, swiftData, router)
    }

    // MARK: - Fetch Transfers

    @Test("Fetch transfers - returns all transfers formatted")
    func fetchTransfersSuccess() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedTransfers())
        
        viewModel.loadTransfers()
        try await Task.sleep(nanoseconds: 100_000_000) // Wait for async task
        
        #expect(viewModel.displayedTransfers.count == 5)
        #expect(viewModel.isLoading == false)
    }

    @Test("Fetch transfers - empty SwiftData returns empty array")
    func fetchTransfersEmpty() async throws {
        let (viewModel, _, _, _) = makeSUT()
        
        viewModel.loadTransfers()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.displayedTransfers.isEmpty)
        #expect(viewModel.isLoading == false)
    }

    @Test("Fetch transfers - formats amounts correctly")
    func fetchTransfersFormatsAmounts() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed([
            TestDataBuilder.createTransfer(id: "1", amount: 100.50),
            TestDataBuilder.createTransfer(id: "2", amount: -50.25)
        ])
        
        viewModel.loadTransfers()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        let positiveTransfer = viewModel.displayedTransfers.first { $0.id == "1" }
        let negativeTransfer = viewModel.displayedTransfers.first { $0.id == "2" }
        
        #expect(positiveTransfer?.amount == "+€100.50")
        #expect(negativeTransfer?.amount == "-€50.25")
    }

    @Test("Fetch transfers - large dataset 1000 transfers")
    func fetchTransfersLargeDataset() async throws {
        let (viewModel, _, swiftData, _) = makeSUT()
        swiftData.seed(TestDataBuilder.createTransfers(count: 1000))
        
        viewModel.loadTransfers()
        try await Task.sleep(nanoseconds: 200_000_000)
        
        #expect(viewModel.displayedTransfers.count == 1000)
    }

    // MARK: - Delete Transfer

    @Test("Delete transfer - removes transfer and refreshes list")
    func deleteTransferSuccess() async throws {
        let (viewModel, worker, swiftData, _) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedTransfers())
        
        viewModel.deleteTransfer(transferId: "3")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(worker.deleteTransferCallCount == 1)
        #expect(swiftData.transfers.count == 4)
        #expect(swiftData.transfers.contains(where: { $0.id == "3" }) == false)
    }

    // MARK: - Navigation

    @Test("Select transfer - navigates to detail")
    func selectTransferNavigates() {
        let (viewModel, _, _, router) = makeSUT()
        
        viewModel.didSelectTransfer(transferId: "test_123")
        
        #expect(router.navigateToCallCount == 1)
        if case .transferDetail(let id) = router.lastNavigatedRoute {
            #expect(id == "test_123")
        } else {
            Issue.record("Expected transferDetail route")
        }
    }

    @Test("Add transfer - presents sheet")
    func addTransferPresentsSheet() {
        let (viewModel, _, _, router) = makeSUT()
        
        viewModel.didTapAddTransfer()
        
        #expect(router.presentSheetCallCount == 1)
        #expect(router.lastPresentedSheet == .addTransfer)
    }

    @Test("Edit transfer - navigates to edit")
    func editTransferNavigates() {
        let (viewModel, _, _, router) = makeSUT()
        
        viewModel.didTapEditTransfer(transferId: "test_456")
        
        #expect(router.navigateToCallCount == 1)
        if case .editTransfer(let id) = router.lastNavigatedRoute {
            #expect(id == "test_456")
        } else {
            Issue.record("Expected editTransfer route")
        }
    }

    // MARK: - Loading State

    @Test("Loading state - set to true when loading starts")
    func loadingStateTrue() {
        let (viewModel, _, _, _) = makeSUT()
        
        viewModel.loadTransfers()
        
        #expect(viewModel.isLoading == true)
    }
}

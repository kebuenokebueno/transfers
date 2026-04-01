//
//  TransferListIntegrationTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@Suite("TransferList - Full MVVM Integration", .tags(.integration))
struct TransferListIntegrationTests {

    @MainActor
    private func makeStack() -> (
        viewModel: TransferListViewModel,
        worker: MockTransferWorker,
        local: MockSwiftDataService,
        cloud: MockSupabaseService,
        router: MockRouter
    ) {
        let local  = MockSwiftDataService()
        let cloud  = MockSupabaseService()
        let worker = MockTransferWorker(swiftDataService: local, supabaseService: cloud)
        let router = MockRouter()
        let viewModel = TransferListViewModel(
            transferWorker: worker,
            swiftDataService: local,
            router: router
        )
        return (viewModel, worker, local, cloud, router)
    }

    // MARK: - Fetch

    @MainActor @Test("Integration: Fetch - transfers reach ViewModel formatted")
    func integrationFetch() async throws {
        let (viewModel, _, local, _, _) = makeStack()
        local.seed(TestDataBuilder.createMixedTransfers())
        
        viewModel.loadTransfers()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.displayedTransfers.count == 5)
        
        let grocery = viewModel.displayedTransfers.first(where: { $0.description == "Grocery Store" })
        #expect(grocery?.isPositive == false)
        
        let salary = viewModel.displayedTransfers.first(where: { $0.description == "Salary" })
        #expect(salary?.isPositive == true)
    }

    @MainActor @Test("Integration: Fetch - empty store shows empty list")
    func integrationFetchEmpty() async throws {
        let (viewModel, _, _, _, _) = makeStack()
        
        viewModel.loadTransfers()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.displayedTransfers.isEmpty == true)
    }

    // MARK: - Delete then fetch

    @MainActor @Test("Integration: Delete - transfer gone from stores and next fetch")
    func integrationDeleteThenFetch() async throws {
        let (viewModel, _, local, cloud, _) = makeStack()
        let transfers = TestDataBuilder.createMixedTransfers()
        local.seed(transfers)
        cloud.transfers = transfers
        
        viewModel.deleteTransfer(transferId: "2")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(local.transfers.contains(where: { $0.id == "2" }) == false)
        #expect(cloud.transfers.contains(where: { $0.id == "2" }) == false)
        
        // After deletion, the list should be refreshed automatically
        #expect(viewModel.displayedTransfers.count == 4)
        #expect(viewModel.displayedTransfers.contains(where: { $0.id == "2" }) == false)
    }

    @MainActor @Test("Integration: Delete all - list becomes empty")
    func integrationDeleteAll() async throws {
        let (viewModel, _, local, _, _) = makeStack()
        let transfers = TestDataBuilder.createMixedTransfers()
        local.seed(transfers)
        
        for transfer in transfers {
            viewModel.deleteTransfer(transferId: transfer.id)
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(viewModel.displayedTransfers.isEmpty == true)
    }

    // MARK: - Cloud failure paths

    @MainActor @Test("Integration: Cloud down - delete still removes locally")
    func integrationCloudDownDelete() async throws {
        let (viewModel, _, local, cloud, _) = makeStack()
        local.seed([TestDataBuilder.createTransfer(id: "offline_d")])
        cloud.shouldFail = true
        
        viewModel.deleteTransfer(transferId: "offline_d")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(local.transfers.isEmpty)
        #expect(viewModel.displayedTransfers.isEmpty == true)
    }
    
    // MARK: - Navigation
    
    @MainActor @Test("Integration: Navigation - select transfer navigates to detail")
    func integrationNavigateToDetail() async throws {
        let (viewModel, _, local, _, router) = makeStack()
        local.seed(TestDataBuilder.createMixedTransfers())
        
        viewModel.didSelectTransfer(transferId: "3")
        
        #expect(router.navigateToCallCount == 1)
        if case .transferDetail(let id) = router.lastNavigatedRoute {
            #expect(id == "3")
        } else {
            Issue.record("Expected transferDetail route")
        }
    }
    
    @MainActor @Test("Integration: Navigation - add transfer presents sheet")
    func integrationPresentAddTransfer() async throws {
        let (viewModel, _, _, _, router) = makeStack()
        
        viewModel.didTapAddTransfer()
        
        #expect(router.presentSheetCallCount == 1)
        #expect(router.lastPresentedSheet == .addTransfer)
    }
}

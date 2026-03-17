//
//  TransferListIntegrationTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@Suite("TransferList - Full VIP Integration", .tags(.integration))
struct TransferListIntegrationTests {

    @MainActor
    private func makeStack() -> (
        interactor: TransferListInteractor,
        vc: MockTransferListViewController,
        worker: MockTransferWorker,
        local: MockSwiftDataService,
        cloud: MockSupabaseService
    ) {
        let local      = MockSwiftDataService()
        let cloud      = MockSupabaseService()
        let worker     = MockTransferWorker(swiftDataService: local, supabaseService: cloud)
        let interactor = TransferListInteractor(transferWorker: worker, swiftDataService: local)
        let presenter  = TransferListPresenter()
        let vc         = MockTransferListViewController()
        interactor.presenter     = presenter
        presenter.viewController = vc
        return (interactor, vc, worker, local, cloud)
    }

    // MARK: - Fetch

    @MainActor @Test("Integration: Fetch - transfers reach ViewController formatted")
    func integrationFetch() async {
        let (interactor, vc, _, local, _) = makeStack()
        local.seed(TestDataBuilder.createMixedTransfers())
        await interactor.fetchTransfers()
        #expect(vc.displayTransfersCalled == true)
        #expect(vc.lastFetchViewModel?.displayedTransfers.count == 5)
        let grocery = vc.lastFetchViewModel?.displayedTransfers.first(where: { $0.description == "Grocery Store" })
        #expect(grocery?.isPositive == false)
        let salary = vc.lastFetchViewModel?.displayedTransfers.first(where: { $0.description == "Salary" })
        #expect(salary?.isPositive == true)
    }

    @MainActor @Test("Integration: Fetch - empty store shows empty list")
    func integrationFetchEmpty() async {
        let (interactor, vc, _, _, _) = makeStack()
        await interactor.fetchTransfers()
        #expect(vc.displayTransfersCalled == true)
        #expect(vc.lastFetchViewModel?.displayedTransfers.isEmpty == true)
    }

    // MARK: - Delete then fetch

    @MainActor @Test("Integration: Delete - transfer gone from stores and next fetch")
    func integrationDeleteThenFetch() async {
        let (interactor, vc, _, local, cloud) = makeStack()
        let transfers = TestDataBuilder.createMixedTransfers()
        local.seed(transfers)
        cloud.transfers = transfers
        await interactor.deleteTransfer(request: TransferScene.DeleteTransfer.Request(transferId: "2"))
        #expect(vc.displayDeleteResultCalled == true)
        #expect(vc.lastDeleteViewModel?.success == true)
        #expect(local.transfers.contains(where: { $0.id == "2" }) == false)
        #expect(cloud.transfers.contains(where: { $0.id == "2" }) == false)
        await interactor.fetchTransfers()
        #expect(vc.lastFetchViewModel?.displayedTransfers.count == 4)
        #expect(vc.lastFetchViewModel?.displayedTransfers.contains(where: { $0.id == "2" }) == false)
    }

    @MainActor @Test("Integration: Delete all - list becomes empty")
    func integrationDeleteAll() async {
        let (interactor, vc, _, local, _) = makeStack()
        let transfers = TestDataBuilder.createMixedTransfers()
        local.seed(transfers)
        for transfer in transfers {
            await interactor.deleteTransfer(request: TransferScene.DeleteTransfer.Request(transferId: transfer.id))
        }
        await interactor.fetchTransfers()
        #expect(vc.lastFetchViewModel?.displayedTransfers.isEmpty == true)
    }

    // MARK: - Cloud failure paths

    @MainActor @Test("Integration: Cloud down - delete still removes locally")
    func integrationCloudDownDelete() async {
        let (interactor, vc, _, local, cloud) = makeStack()
        local.seed([TestDataBuilder.createTransfer(id: "offline_d")])
        cloud.shouldFail = true
        await interactor.deleteTransfer(request: TransferScene.DeleteTransfer.Request(transferId: "offline_d"))
        #expect(local.transfers.isEmpty)
        await interactor.fetchTransfers()
        #expect(vc.lastFetchViewModel?.displayedTransfers.isEmpty == true)
    }
}

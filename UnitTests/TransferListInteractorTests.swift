//
//  TransferListInteractorTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("TransferList Interactor Tests", .tags(.unit, .interactor))
struct TransferListInteractorTests {

    private func makeSUT() -> (
        interactor: TransferListInteractor,
        presenter: MockTransferListPresenter,
        worker: MockTransferWorker,
        swiftData: MockSwiftDataService
    ) {
        let swiftData  = MockSwiftDataService()
        let supabase   = MockSupabaseService()
        let worker     = MockTransferWorker(swiftDataService: swiftData, supabaseService: supabase)
        let interactor = TransferListInteractor(transferWorker: worker, swiftDataService: swiftData)
        let presenter  = MockTransferListPresenter()
        interactor.presenter = presenter
        return (interactor, presenter, worker, swiftData)
    }

    // MARK: - Fetch Transfers

    @Test("Fetch transfers - returns all transfers from SwiftData")
    func fetchTransfersSuccess() async {
        let (interactor, presenter, _, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedTransfers())
        await interactor.fetchTransfers()
        #expect(presenter.presentTransfersCalled == true)
        #expect(presenter.lastFetchResponse?.transfers.count == 5)
    }

    @Test("Fetch transfers - empty SwiftData still calls presenter")
    func fetchTransfersEmpty() async {
        let (interactor, presenter, _, _) = makeSUT()
        await interactor.fetchTransfers()
        #expect(presenter.presentTransfersCalled == true)
        #expect(presenter.lastFetchResponse?.transfers.isEmpty == true)
    }

    @Test("Fetch transfers - large dataset 1000 transfers")
    func fetchTransfersLargeDataset() async {
        let (interactor, presenter, _, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createTransfers(count: 1000))
        await interactor.fetchTransfers()
        #expect(presenter.lastFetchResponse?.transfers.count == 1000)
    }

    @Test("Fetch transfers - nil presenter does not crash")
    func fetchTransfersNilPresenter() async {
        let (interactor, _, _, swiftData) = makeSUT()
        interactor.presenter = nil
        swiftData.seed(TestDataBuilder.createMixedTransfers())
        await interactor.fetchTransfers()
        #expect(true)
    }

    @Test("Fetch transfers - presenter called once when empty")
    func fetchTransfersCallCountEmpty() async {
        let (interactor, presenter, _, _) = makeSUT()
        await interactor.fetchTransfers()
        #expect(presenter.presentTransfersCallCount == 1)
    }

    @Test("Fetch transfers - presenter called twice when SwiftData has data")
    func fetchTransfersCallCountWithData() async {
        let (interactor, presenter, _, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedTransfers())
        await interactor.fetchTransfers()
        #expect(presenter.presentTransfersCallCount == 2)
    }

    // MARK: - Delete Transfer

    @Test("Delete transfer - removes from SwiftData and calls presenter")
    func deleteTransferSuccess() async {
        let (interactor, presenter, worker, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedTransfers())
        await interactor.deleteTransfer(request: TransferScene.DeleteTransfer.Request(transferId: "3"))
        #expect(presenter.presentDeleteResultCalled == true)
        #expect(presenter.lastDeleteResponse?.success == true)
        #expect(presenter.lastDeleteResponse?.transferId == "3")
        #expect(swiftData.transfers.count == 4)
        #expect(swiftData.transfers.contains(where: { $0.id == "3" }) == false)
        #expect(worker.deleteTransferCallCount == 1)
    }

    @Test("Delete transfer - non-existent id still reports success")
    func deleteTransferNotFound() async {
        let (interactor, presenter, _, _) = makeSUT()
        await interactor.deleteTransfer(request: TransferScene.DeleteTransfer.Request(transferId: "ghost"))
        #expect(presenter.presentDeleteResultCalled == true)
    }

    @Test("Delete transfer - delete all transfers one by one")
    func deleteTransferAll() async {
        let (interactor, _, _, swiftData) = makeSUT()
        let transfers = TestDataBuilder.createMixedTransfers()
        swiftData.seed(transfers)
        for transfer in transfers {
            await interactor.deleteTransfer(request: TransferScene.DeleteTransfer.Request(transferId: transfer.id))
        }
        #expect(swiftData.transfers.isEmpty)
    }
}

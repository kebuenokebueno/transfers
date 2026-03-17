//
//  TransferDetailInteractorTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("TransferDetail Interactor Tests", .tags(.unit, .interactor))
struct TransferDetailInteractorTests {

    private func makeSUT() -> (
        interactor: TransferDetailInteractor,
        presenter: MockTransferDetailPresenter,
        worker: MockTransferWorker,
        swiftData: MockSwiftDataService
    ) {
        let swiftData  = MockSwiftDataService()
        let supabase   = MockSupabaseService()
        let worker     = MockTransferWorker(swiftDataService: swiftData, supabaseService: supabase)
        let interactor = TransferDetailInteractor(transferWorker: worker, swiftDataService: swiftData)
        let presenter  = MockTransferDetailPresenter()
        interactor.presenter = presenter
        return (interactor, presenter, worker, swiftData)
    }

    // MARK: - Fetch Transfer

    @Test("Fetch transfer – returns correct transfer")
    func fetchTransferSuccess() async {
        let (interactor, presenter, _, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedNotes())

        await interactor.fetchTransfer(request: TransferDetailScene.FetchNote.Request(transferId: "3"))

        #expect(presenter.presentTransferCalled == true)
        #expect(presenter.lastFetchResponse?.transfer?.id == "3")
        #expect(presenter.lastFetchResponse?.transfer?.noteDescription == "Salary")
    }

    @Test("Fetch transfer – missing id returns nil")
    func fetchTransferMissing() async {
        let (interactor, presenter, _, _) = makeSUT()

        await interactor.fetchTransfer(request: TransferDetailScene.FetchNote.Request(transferId: "missing"))

        #expect(presenter.presentTransferCalled == true)
        #expect(presenter.lastFetchResponse?.transfer == nil)
    }

    @Test("Fetch transfer – nil presenter does not crash")
    func fetchTransferNilPresenter() async {
        let (interactor, _, _, swiftData) = makeSUT()
        interactor.presenter = nil
        swiftData.seed(TestDataBuilder.createMixedNotes())

        await interactor.fetchTransfer(request: TransferDetailScene.FetchNote.Request(transferId: "1"))
        #expect(true)
    }

    // MARK: - Delete Transfer

    @Test("Delete transfer – removes from SwiftData and calls presenter")
    func deleteTransferSuccess() async {
        let (interactor, presenter, worker, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedNotes())

        await interactor.deleteTransfer(request: TransferDetailScene.DeleteTransfer.Request(transferId: "3"))

        #expect(presenter.presentDeleteResultCalled == true)
        #expect(presenter.lastDeleteResponse?.success == true)
        #expect(worker.deleteTransferCallCount == 1)
        #expect(swiftData.transfers.contains(where: { $0.id == "3" }) == false)
    }

    @Test("Delete transfer – non-existent id still reports success")
    func deleteTransferNotFound() async {
        let (interactor, presenter, _, _) = makeSUT()

        await interactor.deleteTransfer(request: TransferDetailScene.DeleteTransfer.Request(transferId: "ghost"))

        #expect(presenter.presentDeleteResultCalled == true)
        #expect(presenter.lastDeleteResponse?.success == true)
    }

    @Test("Delete transfer – nil presenter does not crash")
    func deleteTransferNilPresenter() async {
        let (interactor, _, _, swiftData) = makeSUT()
        interactor.presenter = nil
        swiftData.seed([TestDataBuilder.createTransfer(id: "x")])

        await interactor.deleteTransfer(request: TransferDetailScene.DeleteTransfer.Request(transferId: "x"))
        #expect(true)
    }
}

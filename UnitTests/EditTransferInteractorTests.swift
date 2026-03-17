//
//  EditTransferInteractorTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("EditTransfer Interactor Tests", .tags(.unit, .interactor))
struct EditTransferInteractorTests {

    private func makeSUT() -> (
        interactor: EditTransferInteractor,
        presenter: MockEditTransferPresenter,
        worker: MockTransferWorker,
        swiftData: MockSwiftDataService
    ) {
        let swiftData  = MockSwiftDataService()
        let supabase   = MockSupabaseService()
        let worker     = MockTransferWorker(swiftDataService: swiftData, supabaseService: supabase)
        let interactor = EditTransferInteractor(transferWorker: worker, swiftDataService: swiftData)
        let presenter  = MockEditTransferPresenter()
        interactor.presenter = presenter
        return (interactor, presenter, worker, swiftData)
    }

    // MARK: - Load Transfer

    @Test("Load transfer – returns correct transfer")
    func loadTransferSuccess() async {
        let (interactor, presenter, _, swiftData) = makeSUT()
        swiftData.seed(TestDataBuilder.createMixedTransfers())

        await interactor.loadTransfer(request: EditTransferScene.LoadTransfer.Request(transferId: "3"))

        #expect(presenter.presentTransferCalled == true)
        #expect(presenter.lastLoadResponse?.transfer?.id == "3")
        #expect(presenter.lastLoadResponse?.transfer?.transferDescription == "Salary")
    }

    @Test("Load transfer – missing id returns nil")
    func loadTransferMissing() async {
        let (interactor, presenter, _, _) = makeSUT()

        await interactor.loadTransfer(request: EditTransferScene.LoadTransfer.Request(transferId: "missing"))

        #expect(presenter.presentTransferCalled == true)
        #expect(presenter.lastLoadResponse?.transfer == nil)
    }

    // MARK: - Save Transfer

    @Test("Save transfer – changes persist to SwiftData")
    func saveTransferSuccess() async {
        let (interactor, presenter, worker, swiftData) = makeSUT()
        let original = TestDataBuilder.createTransfer(id: "upd_1", amount: -50.00, description: "Old Name", category: "Food")
        swiftData.seed([original])

        await interactor.saveTransfer(request: EditTransferScene.SaveTransfer.Request(
            transferId: "upd_1",
            amount: 99.99,
            description: "New Name",
            category: "Entertainment",
            isPositive: false
        ))

        #expect(presenter.presentSaveResultCalled == true)
        #expect(presenter.lastSaveResponse?.success == true)
        #expect(worker.updateTransferCallCount == 1)
        let updated = swiftData.transfers.first(where: { $0.id == "upd_1" })
        #expect(updated?.transferDescription == "New Name")
        #expect(updated?.category == "Entertainment")
        #expect(updated?.amount == -99.99)
    }

    @Test("Save transfer – non-existent id reports failure")
    func saveTransferNotFound() async {
        let (interactor, presenter, _, _) = makeSUT()

        await interactor.saveTransfer(request: EditTransferScene.SaveTransfer.Request(
            transferId: "ghost",
            amount: 10.00,
            description: "Ghost",
            category: "Other",
            isPositive: false
        ))

        #expect(presenter.presentSaveResultCalled == true)
        #expect(presenter.lastSaveResponse?.success == false)
    }

    @Test("Save transfer – sync status set to pending")
    func saveTransferSyncStatus() async {
        let (interactor, _, _, swiftData) = makeSUT()
        let original = TestDataBuilder.createTransfer(id: "sync_1", syncStatus: "synced")
        swiftData.seed([original])

        await interactor.saveTransfer(request: EditTransferScene.SaveTransfer.Request(
            transferId: "sync_1",
            amount: 1.00,
            description: "Trigger sync",
            category: "Other",
            isPositive: false
        ))

        let updated = swiftData.transfers.first(where: { $0.id == "sync_1" })
        #expect(updated?.syncStatus == "pending")
    }

    @Test("Save transfer – nil presenter does not crash")
    func saveTransferNilPresenter() async {
        let (interactor, _, _, swiftData) = makeSUT()
        interactor.presenter = nil
        swiftData.seed([TestDataBuilder.createTransfer(id: "x")])

        await interactor.saveTransfer(request: EditTransferScene.SaveTransfer.Request(
            transferId: "x",
            amount: 5.00,
            description: "Test",
            category: "Food",
            isPositive: false
        ))
        #expect(true)
    }
}

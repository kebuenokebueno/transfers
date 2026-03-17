//
//  TransferListPresenterTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@Suite("TransferList Presenter Tests", .tags(.unit, .presenter))
struct TransferListPresenterTests {

    @MainActor
    private func makeSUT() -> (presenter: TransferListPresenter, vc: MockTransferListViewController) {
        let presenter = TransferListPresenter()
        let vc        = MockTransferListViewController()
        presenter.viewController = vc
        return (presenter, vc)
    }

    // MARK: - Present Transfers

    @MainActor @Test("Present transfers - formats expense with minus and euro")
    func presentTransfersFormatsExpense() {
        let (presenter, vc) = makeSUT()
        let transfer = TestDataBuilder.createTransfer(id: "1", amount: -45.50, description: "Grocery Store", category: "Food")
        presenter.presentTransfers(response: TransferScene.FetchTransfers.Response(transfers: [transfer]))
        let displayed = vc.lastFetchViewModel?.displayedTransfers.first
        #expect(vc.displayTransfersCalled == true)
        #expect(displayed?.amount.contains("45") == true)
        #expect(displayed?.amount.contains("-") == true)
        #expect(displayed?.isPositive == false)
    }

    @MainActor @Test("Present transfers - formats income with plus")
    func presentTransfersFormatsIncome() {
        let (presenter, vc) = makeSUT()
        let transfer = TestDataBuilder.createTransfer(id: "2", amount: 2500.00, description: "Salary", category: "Income")
        presenter.presentTransfers(response: TransferScene.FetchTransfers.Response(transfers: [transfer]))
        let displayed = vc.lastFetchViewModel?.displayedTransfers.first
        #expect(displayed?.isPositive == true)
        #expect(displayed?.amount.contains("+") == true)
        #expect(displayed?.category == "Income")
    }

    @MainActor @Test("Present transfers - formats date correctly")
    func presentTransfersFormatsDate() {
        let (presenter, vc) = makeSUT()
        let testDate = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 25))!
        let transfer = TestDataBuilder.createTransfer(id: "1", amount: -10.0, date: testDate)
        presenter.presentTransfers(response: TransferScene.FetchTransfers.Response(transfers: [transfer]))
        let displayed = vc.lastFetchViewModel?.displayedTransfers.first
        #expect(displayed?.date.contains("Jan") == true || displayed?.date.contains("2026") == true)
    }

    @MainActor @Test("Present transfers - empty list still calls ViewController")
    func presentTransfersEmpty() {
        let (presenter, vc) = makeSUT()
        presenter.presentTransfers(response: TransferScene.FetchTransfers.Response(transfers: []))
        #expect(vc.displayTransfersCalled == true)
        #expect(vc.lastFetchViewModel?.displayedTransfers.isEmpty == true)
    }

    @MainActor @Test("Present transfers - preserves order")
    func presentTransfersOrder() {
        let (presenter, vc) = makeSUT()
        let transfers = [
            TestDataBuilder.createTransfer(id: "A", description: "First"),
            TestDataBuilder.createTransfer(id: "B", description: "Second"),
            TestDataBuilder.createTransfer(id: "C", description: "Third")
        ]
        presenter.presentTransfers(response: TransferScene.FetchTransfers.Response(transfers: transfers))
        let displayed = vc.lastFetchViewModel?.displayedTransfers ?? []
        #expect(displayed.count == 3)
        #expect(displayed[0].id == "A")
        #expect(displayed[1].id == "B")
        #expect(displayed[2].id == "C")
    }

    @MainActor @Test("Present transfers - zero amount treated as positive")
    func presentTransfersZeroAmount() {
        let (presenter, vc) = makeSUT()
        presenter.presentTransfers(response: TransferScene.FetchTransfers.Response(transfers: [
            TestDataBuilder.createTransfer(id: "z", amount: 0.0)
        ]))
        #expect(vc.lastFetchViewModel?.displayedTransfers.first?.isPositive == true)
    }

    @MainActor @Test("Present transfers - nil ViewController does not crash")
    func presentTransfersNilVC() {
        let presenter = TransferListPresenter()
        presenter.viewController = nil
        presenter.presentTransfers(response: TransferScene.FetchTransfers.Response(transfers: [
            TestDataBuilder.createTransfer(id: "x")
        ]))
        #expect(true)
    }

    @MainActor @Test("Present transfers - called twice, VC sees latest")
    func presentTransfersMultipleCalls() {
        let (presenter, vc) = makeSUT()
        presenter.presentTransfers(response: TransferScene.FetchTransfers.Response(transfers: [TestDataBuilder.createTransfer(id: "1")]))
        presenter.presentTransfers(response: TransferScene.FetchTransfers.Response(transfers: TestDataBuilder.createMixedTransfers()))
        #expect(vc.displayTransfersCallCount == 2)
        #expect(vc.lastFetchViewModel?.displayedTransfers.count == 5)
    }

    // MARK: - Present Delete Result

    @MainActor @Test("Present delete result - success carries message")
    func presentDeleteSuccess() {
        let (presenter, vc) = makeSUT()
        presenter.presentDeleteResult(response: TransferScene.DeleteTransfer.Response(success: true, transferId: "del_1"))
        #expect(vc.displayDeleteResultCalled == true)
        #expect(vc.lastDeleteViewModel?.success == true)
        #expect(vc.lastDeleteViewModel?.message != nil)
    }

    @MainActor @Test("Present delete result - failure carries message")
    func presentDeleteFailure() {
        let (presenter, vc) = makeSUT()
        presenter.presentDeleteResult(response: TransferScene.DeleteTransfer.Response(success: false, transferId: "del_fail"))
        #expect(vc.displayDeleteResultCalled == true)
        #expect(vc.lastDeleteViewModel?.success == false)
        #expect(vc.lastDeleteViewModel?.message != nil)
    }
}

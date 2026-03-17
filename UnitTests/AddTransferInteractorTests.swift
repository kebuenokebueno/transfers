//
//  AddTransferInteractorTests.swift
//  TransfersTests
//

import Testing
import Foundation
@testable import Transfers

@MainActor
@Suite("AddTransfer Interactor Tests", .tags(.unit, .interactor))
struct AddTransferInteractorTests {

    private func makeSUT() -> (
        interactor: AddTransferInteractor,
        presenter: MockAddTransferPresenter,
        worker: MockTransferWorker,
        swiftData: MockSwiftDataService
    ) {
        let swiftData  = MockSwiftDataService()
        let supabase   = MockSupabaseService()
        let worker     = MockTransferWorker(swiftDataService: swiftData, supabaseService: supabase)
        let interactor = AddTransferInteractor(transferWorker: worker)
        let presenter  = MockAddTransferPresenter()
        interactor.presenter = presenter
        return (interactor, presenter, worker, swiftData)
    }

    @Test("Save transfer – expense stored as negative amount")
    func saveTransferExpense() async {
        let (interactor, presenter, worker, swiftData) = makeSUT()

        await interactor.saveTransfer(request: AddTransferScene.SaveTransfer.Request(
            amount: 75.00,
            description: "Coffee Shop",
            category: "Food",
            isIncome: false
        ))

        #expect(presenter.presentSaveResultCalled == true)
        #expect(presenter.lastSaveResponse?.success == true)
        #expect(worker.createTransferCallCount == 1)
        #expect(swiftData.transfers.count == 1)
        #expect(swiftData.transfers.first?.amount == -75.00)
        #expect(swiftData.transfers.first?.transferDescription == "Coffee Shop")
    }

    @Test("Save transfer – income flag keeps amount positive")
    func saveTransferIncome() async {
        let (interactor, presenter, _, swiftData) = makeSUT()

        await interactor.saveTransfer(request: AddTransferScene.SaveTransfer.Request(
            amount: 2500.00,
            description: "Salary",
            category: "Income",
            isIncome: true
        ))

        #expect(presenter.lastSaveResponse?.success == true)
        #expect(swiftData.transfers.first?.amount == 2500.00)
    }

    @Test("Save transfer – multiple transfers accumulate")
    func saveTransferMultiple() async {
        let (interactor, _, _, swiftData) = makeSUT()

        for i in 1...3 {
            await interactor.saveTransfer(request: AddTransferScene.SaveTransfer.Request(
                amount: Double(i * 10),
                description: "Transfer \(i)",
                category: "Food",
                isIncome: false
            ))
        }

        #expect(swiftData.transfers.count == 3)
    }

    @Test("Save transfer – nil presenter does not crash")
    func saveTransferNilPresenter() async {
        let (interactor, _, _, _) = makeSUT()
        interactor.presenter = nil

        await interactor.saveTransfer(request: AddTransferScene.SaveTransfer.Request(
            amount: 10.00,
            description: "Test",
            category: "Other",
            isIncome: false
        ))
        #expect(true)
    }
}

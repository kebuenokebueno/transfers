//
//  AddTransferInteractor.swift
//  Transfers
//

import Foundation

protocol AddTransferBusinessLogic {
    func saveTransfer(request: AddTransferScene.SaveNote.Request) async
}

@MainActor
class AddTransferInteractor: AddTransferBusinessLogic {
    var presenter: AddTransferPresentationLogic?

    private let transferWorker: TransferWorkerProtocol

    init(transferWorker: TransferWorkerProtocol) {
        self.transferWorker = transferWorker
    }

    func saveTransfer(request: AddTransferScene.SaveNote.Request) async {
        let transfer = TransferEntity(
            id: UUID().uuidString,
            amount: request.isIncome ? request.amount : -request.amount,
            description: request.description,
            date: Date(),
            category: request.category,
            syncStatus: .pending
        )
        await transferWorker.createTransfer(transfer)
        let response = AddTransferScene.SaveNote.Response(success: true)
        await MainActor.run { presenter?.presentSaveResult(response: response) }
    }
}

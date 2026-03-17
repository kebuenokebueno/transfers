//
//  EditTransferInteractor.swift
//  Transfers
//

import Foundation

protocol EditTransferBusinessLogic {
    func loadTransfer(request: EditTransferScene.LoadTransfer.Request) async
    func saveTransfer(request: EditTransferScene.SaveTransfer.Request) async
}

@MainActor
class EditTransferInteractor: EditTransferBusinessLogic {
    var presenter: EditTransferPresentationLogic?
    var transferId: String?

    private let transferWorker: TransferWorkerProtocol
    private let swiftDataService: SwiftDataServiceProtocol

    init(transferWorker: TransferWorkerProtocol, swiftDataService: SwiftDataServiceProtocol) {
        self.transferWorker = transferWorker
        self.swiftDataService = swiftDataService
    }

    func loadTransfer(request: EditTransferScene.LoadTransfer.Request) async {
        let transfer = try? swiftDataService.fetchTransfer(id: request.transferId)
        let response = EditTransferScene.LoadTransfer.Response(transfer: transfer)
        await MainActor.run { presenter?.presentTransfer(response: response) }
    }

    func saveTransfer(request: EditTransferScene.SaveTransfer.Request) async {
        guard let existing = try? swiftDataService.fetchTransfer(id: request.transferId) else {
            let response = EditTransferScene.SaveTransfer.Response(success: false)
            await MainActor.run { presenter?.presentSaveResult(response: response) }
            return
        }
        existing.amount = request.isPositive ? request.amount : -request.amount
        existing.transferDescription = request.description
        existing.category = request.category
        await transferWorker.updateTransfer(existing)
        let response = EditTransferScene.SaveTransfer.Response(success: true)
        await MainActor.run { presenter?.presentSaveResult(response: response) }
    }
}

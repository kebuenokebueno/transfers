//
//  TransferDetailInteractor.swift
//  Transfers
//

import Foundation

protocol TransferDetailBusinessLogic {
    func fetchTransfer(request: TransferDetailScene.FetchTransfer.Request) async
    func deleteTransfer(request: TransferDetailScene.DeleteTransfer.Request) async
}

@MainActor
class TransferDetailInteractor: TransferDetailBusinessLogic {
    var presenter: TransferDetailPresentationLogic?
    var transferId: String?

    private let transferWorker: TransferWorkerProtocol
    private let swiftDataService: SwiftDataServiceProtocol

    init(transferWorker: TransferWorkerProtocol, swiftDataService: SwiftDataServiceProtocol) {
        self.transferWorker = transferWorker
        self.swiftDataService = swiftDataService
    }

    func fetchTransfer(request: TransferDetailScene.FetchTransfer.Request) async {
        let transfer = try? swiftDataService.fetchTransfer(id: request.transferId)
        let response = TransferDetailScene.FetchTransfer.Response(transfer: transfer)
        await MainActor.run { presenter?.presentTransfer(response: response) }
    }

    func deleteTransfer(request: TransferDetailScene.DeleteTransfer.Request) async {
        await transferWorker.deleteTransfer(id: request.transferId)
        let response = TransferDetailScene.DeleteTransfer.Response(success: true)
        await MainActor.run { presenter?.presentDeleteResult(response: response) }
    }
}

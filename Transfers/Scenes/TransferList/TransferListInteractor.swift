//
//  TransferListInteractor.swift
//  Transfers
//

import Foundation

protocol TransferListBusinessLogic {
    func fetchTransfers() async
    func deleteTransfer(request: TransferScene.DeleteTransfer.Request) async
}

@MainActor
class TransferListInteractor: TransferListBusinessLogic {
    var presenter: TransferListPresentationLogic?
    var selectedTransferId: String?                       // ← Router reads this

    private let transferWorker: TransferWorkerProtocol
    private let swiftDataService: SwiftDataServiceProtocol

    init(transferWorker: TransferWorkerProtocol, swiftDataService: SwiftDataServiceProtocol) {
        self.transferWorker = transferWorker
        self.swiftDataService = swiftDataService
    }

    // MARK: - Fetch Transfers

    func fetchTransfers() async {
        let localTransfers = (try? swiftDataService.fetchTransfers()) ?? []
        if !localTransfers.isEmpty {
            let response = TransferScene.FetchTransfers.Response(transfers: localTransfers)
            await MainActor.run { presenter?.presentTransfers(response: response) }
        }
        await transferWorker.fetchTransfers()
        let updatedTransfers = (try? swiftDataService.fetchTransfers()) ?? []
        let response = TransferScene.FetchTransfers.Response(transfers: updatedTransfers)
        await MainActor.run { presenter?.presentTransfers(response: response) }
    }

    // MARK: - Delete Transfer

    func deleteTransfer(request: TransferScene.DeleteTransfer.Request) async {
        await transferWorker.deleteTransfer(id: request.transferId)
        let response = TransferScene.DeleteTransfer.Response(success: true, transferId: request.transferId)
        await MainActor.run { presenter?.presentDeleteResult(response: response) }
    }
}

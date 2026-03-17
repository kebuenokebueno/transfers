//
//  TransferListRouter.swift
//  Transfers
//

import Foundation

protocol TransferListRoutingLogic {
    func routeToTransferDetail(transferId: String)
    func routeToAddTransfer()
    func routeToEditTransfer(transferId: String)
}

@MainActor
class TransferListRouter: TransferListRoutingLogic {

    private let router: Router

    init(router: Router) {
        self.router = router
    }

    // MARK: - Navigation + Data Transfer

    func routeToTransferDetail(transferId: String) {
        router.navigate(to: .noteDetail(id: transferId))
    }

    func routeToAddTransfer() {
        router.present(sheet: .addNote)
    }

    func routeToEditTransfer(transferId: String) {
        router.navigate(to: .editNote(id: transferId))
    }
}

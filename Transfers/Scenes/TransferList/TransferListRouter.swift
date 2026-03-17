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
        router.navigate(to: .transferDetail(id: transferId))
    }

    func routeToAddTransfer() {
        router.present(sheet: .addTransfer)
    }

    func routeToEditTransfer(transferId: String) {
        router.navigate(to: .editTransfer(id: transferId))
    }
}

//
//  TransferDetailRouter.swift
//  Transfers
//

import Foundation

protocol TransferDetailRoutingLogic {
    func routeToEditTransfer(transferId: String)
    func dismiss()
}

@MainActor
class TransferDetailRouter: TransferDetailRoutingLogic {

    private let router: Router

    init(router: Router) {
        self.router = router
    }

    func routeToEditTransfer(transferId: String) {
        router.navigate(to: .editNote(id: transferId))
    }

    func dismiss() {
        router.navigateBack()
    }
}

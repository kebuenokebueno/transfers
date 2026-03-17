//
//  EditTransferModels.swift
//  Transfers
//

import Foundation

enum EditTransferScene {

    enum LoadTransfer {
        struct Request {
            let transferId: String
        }
        struct Response {
            let transfer: TransferEntity?
        }
        struct ViewModel {
            let transfer: TransferViewModel?
            let amount: String
            let description: String
            let category: String
        }
    }

    enum SaveTransfer {
        struct Request {
            let transferId: String
            let amount: Double
            let description: String
            let category: String
            let isPositive: Bool
        }
        struct Response {
            let success: Bool
        }
        struct ViewModel {
            let success: Bool
            let message: String
        }
    }
}

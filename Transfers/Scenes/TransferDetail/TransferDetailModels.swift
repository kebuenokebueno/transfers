//
//  TransferDetailModels.swift
//  Transfers
//

import Foundation

enum TransferDetailScene {

    enum FetchTransfer {
        struct Request {
            let transferId: String
        }
        struct Response {
            let transfer: TransferEntity?
        }
        struct ViewModel {
            let transfer: TransferViewModel?
        }
    }

    enum DeleteTransfer {
        struct Request {
            let transferId: String
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

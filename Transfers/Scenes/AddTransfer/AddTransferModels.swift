//
//  AddTransferModels.swift
//  Transfers
//

import Foundation

enum AddTransferScene {

    enum SaveNote {
        struct Request {
            let amount: Double
            let description: String
            let category: String
            let isIncome: Bool
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

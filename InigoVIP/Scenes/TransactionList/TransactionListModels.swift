//
//  TransactionListModels.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

// MARK: - VIP Scene Models
enum TransactionList {
    enum FetchTransactions {
        struct Request {}
        
        struct Response {
            let transactions: [Transfer]
        }
        
        struct ViewModel {
            struct DisplayedTransaction: Identifiable {
                let id: String
                let amount: String
                let description: String
                let date: String
                let category: String
                let isPositive: Bool
                let thumbnailUrl: String?
            }
            let transactions: [DisplayedTransaction]
        }
    }
}

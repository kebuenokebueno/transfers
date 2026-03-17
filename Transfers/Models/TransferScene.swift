//
//  TransferScene.swift
//  Transfers
//
//  Created by Inigo on 3/2/26.
//

import Foundation


enum TransferScene {
    
    // MARK: - Fetch Transfers
    enum FetchTransfers {
        
        struct Response {
            let transfers: [TransferEntity]
        }
        
        struct ViewModel {
            let displayedTransfers: [TransferViewModel]
        }
    }

    // MARK: - Create Transfer
    enum CreateTransfer {
        struct Request {
            let amount: Double
            let description: String
            let category: String
            let isIncome: Bool
        }
        
        struct Response {
            let transfer: TransferEntity
            let success: Bool
        }
        
        struct ViewModel {
            let success: Bool
            let message: String
        }
    }
    
    // MARK: - Update Transfer
    enum UpdateTransfer {
        struct Request {
            let transferId: String
            let amount: Double
            let description: String
            let category: String
        }
        
        struct Response {
            let transfer: TransferEntity
            let success: Bool
        }
        
        struct ViewModel {
            let success: Bool
            let message: String
        }
    }
    
    // MARK: - Delete Transfer
    enum DeleteTransfer {
        struct Request {
            let transferId: String
        }
        
        struct Response {
            let success: Bool
            let transferId: String
        }
        
        struct ViewModel {
            let success: Bool
            let message: String
        }
    }
    
    // MARK: - Fetch Single Transfer
    enum FetchTransfer {
        struct Request {
            let transferId: String
        }
        
        struct Response {
            let transfer: TransferEntity?
        }
        
        struct ViewModel {
            let displayedTransfer: TransferViewModel?
        }
    }
}

//
//  TransactionListInteractor.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation


protocol TransactionListInteractorProtocol {
    func fetchTransactions() async
}


@MainActor
class TransactionListInteractor: TransactionListInteractorProtocol {
    var presenter: TransactionListPresenterProtocol?
    
    // ✅ Interactor only knows about Workers
    let transactionWorker: TransactionWorkerProtocol
    let analyticsWorker: AnalyticsWorkerProtocol
    
    init(
        transactionWorker: TransactionWorkerProtocol = TransactionWorker(),
        analyticsWorker: AnalyticsWorkerProtocol
    ) {
        self.transactionWorker = transactionWorker
        self.analyticsWorker = analyticsWorker
    }
    
    func fetchTransactions() async {
        // ✅ Uses Worker to track (Worker uses Service internally)
        await analyticsWorker.trackEvent("fetch_transactions_started")
        
        do {
            // ✅ Uses Worker to fetch (Worker uses Service internally)
            let transactions = try await transactionWorker.fetchTransactions()
            
            await analyticsWorker.trackEvent("fetch_transactions_success: \(transactions.count) items")
            
            let response = TransactionList.FetchTransactions.Response(
                transactions: transactions
            )
            await presenter?.presentTransactions(response: response)
        } catch {
            await analyticsWorker.trackEvent("fetch_transactions_error: \(error.localizedDescription)")
            print("Error fetching transactions: \(error)")
        }
    }
}

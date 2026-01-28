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
    let worker: TransactionWorkerProtocol
    let analyticsService: AnalyticsService?
    
    init(worker: TransactionWorkerProtocol = TransactionWorker(),
         analyticsService: AnalyticsService? = nil) {
        self.worker = worker
        self.analyticsService = analyticsService
    }
    
    func fetchTransactions() async {
        analyticsService?.track(event: "fetch_transactions_started")
        
        do {
            let transactions = try await worker.fetchTransactions()
            let response = TransactionList.FetchTransactions.Response(
                transactions: transactions
            )
            await presenter?.presentTransactions(response: response)
            
            analyticsService?.track(event: "fetch_transactions_success: \(transactions.count) items")
        } catch {
            analyticsService?.track(event: "fetch_transactions_error: \(error.localizedDescription)")
            print("Error fetching transactions: \(error)")
        }
    }
}

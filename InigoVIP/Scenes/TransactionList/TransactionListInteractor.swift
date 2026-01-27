//
//  TransactionListInteractor.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

protocol TransactionListInteractorProtocol {
    func fetchTransactions() async
}

@MainActor
class TransactionListInteractor: TransactionListInteractorProtocol {
    var presenter: TransactionListPresenterProtocol?
    let worker: TransactionWorkerProtocol
    
    init(worker: TransactionWorkerProtocol = TransactionWorker()) {
        self.worker = worker
    }
    
    func fetchTransactions() async {
        do {
            let transactions = try await worker.fetchTransactions()
            let response = TransactionList.FetchTransactions.Response(
                transactions: transactions
            )
            await presenter?.presentTransactions(response: response)
        } catch {
            // Handle error
            print("Error fetching transactions: \(error)")
        }
    }
}

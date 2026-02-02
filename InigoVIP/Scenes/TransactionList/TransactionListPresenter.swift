//
//  TransactionListPresenter.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation

// MARK: - Presenter Protocol
protocol TransactionListPresenterProtocol {
    func presentTransactions(response: TransactionList.FetchTransactions.Response)
}

// MARK: - Presenter
@MainActor
class TransactionListPresenter: TransactionListPresenterProtocol {
    weak var viewController: TransactionListViewControllerProtocol?
    
    func presentTransactions(response: TransactionList.FetchTransactions.Response) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = "€"
        
        let displayedTransactions = response.transactions.map { transaction in
            TransactionList.FetchTransactions.ViewModel.DisplayedTransaction(
                id: transaction.id,
                amount: numberFormatter.string(from: NSNumber(value: abs(transaction.amount))) ?? "",
                description: transaction.transactionDescription,
                date: dateFormatter.string(from: transaction.date),
                category: transaction.category,
                isPositive: transaction.amount >= 0,
                thumbnailUrl: transaction.thumbnailUrl
            )
        }
                
        let viewModel = TransactionList.FetchTransactions.ViewModel(
            transactions: displayedTransactions
        )
        viewController?.displayTransactions(viewModel: viewModel)
    }
}

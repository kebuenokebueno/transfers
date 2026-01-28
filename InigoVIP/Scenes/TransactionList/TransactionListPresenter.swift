//
//  TransactionListPresenter.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation

// MARK: - Presenter Protocol
// MARK: - Presenter Protocol
protocol TransactionListPresenterProtocol {
    func presentTransactions(response: TransactionList.FetchTransactions.Response)
}

// MARK: - Presenter
@MainActor
class TransactionListPresenter: TransactionListPresenterProtocol {
    weak var viewController: TransactionListViewControllerProtocol?
    
    func presentTransactions(response: TransactionList.FetchTransactions.Response) {
        print("🟠 Presenter: presentTransactions() called with \(response.transactions.count) transactions")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = "€"
        
        let displayedTransactions = response.transactions.map { transaction in
            TransactionList.FetchTransactions.ViewModel.DisplayedTransaction(
                id: transaction.id,
                amount: numberFormatter.string(from: NSNumber(value: abs(transaction.amount))) ?? "",
                description: transaction.description,
                date: dateFormatter.string(from: transaction.date),
                category: transaction.category,
                isPositive: transaction.amount >= 0
            )
        }
        
        print("🟠 Presenter: Formatted \(displayedTransactions.count) displayed transactions")
        
        let viewModel = TransactionList.FetchTransactions.ViewModel(
            transactions: displayedTransactions
        )
        
        print("🟠 Presenter: About to call viewController.displayTransactions()")
        print("🟠 Presenter: viewController is \(viewController == nil ? "nil" : "not nil")")
        viewController?.displayTransactions(viewModel: viewModel)
        print("🟠 Presenter: viewController.displayTransactions() completed")
    }
}

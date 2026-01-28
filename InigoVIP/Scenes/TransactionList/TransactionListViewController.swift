//
//  TransactionListViewController.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation
internal import Combine

@MainActor
protocol TransactionListViewControllerProtocol: AnyObject {
    func displayTransactions(viewModel: TransactionList.FetchTransactions.ViewModel)
}

// MARK: - View Controller (ViewModel for SwiftUI)
@MainActor
@Observable
class TransactionListViewController: TransactionListViewControllerProtocol {
    var displayedTransactions: [TransactionList.FetchTransactions.ViewModel.DisplayedTransaction] = []
    var isLoading = false
    
    var interactor: TransactionListInteractorProtocol?
    
    init(analyticsService: AnalyticsService? = nil) {
        setupVIP(analyticsService: analyticsService)
    }
    
    private func setupVIP(analyticsService: AnalyticsService?) {
        let interactor = TransactionListInteractor(analyticsService: analyticsService)
        let presenter = TransactionListPresenter()
        
        self.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = self
    }
    
    func loadTransactions() {
        isLoading = true
        Task {
            await interactor?.fetchTransactions()
            isLoading = false
        }
    }
    
    func displayTransactions(viewModel: TransactionList.FetchTransactions.ViewModel) {
        displayedTransactions = viewModel.transactions
    }
}

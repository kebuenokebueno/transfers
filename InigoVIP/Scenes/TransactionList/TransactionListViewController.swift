//
//  TransactionListViewController.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation
internal import Combine

// MARK: - View Controller Protocol
@MainActor
protocol TransactionListViewControllerProtocol: AnyObject {
    func displayTransactions(viewModel: TransactionList.FetchTransactions.ViewModel)
}

// MARK: - View Controller (ViewModel for SwiftUI)
@MainActor
@Observable
class TransactionListViewController: TransactionListViewControllerProtocol {
    @Published var displayedTransactions: [TransactionList.FetchTransactions.ViewModel.DisplayedTransaction] = []
    @Published var isLoading = false
    
    var interactor: TransactionListInteractorProtocol?
    
    init() {
        setupVIP()
    }
    
    private func setupVIP() {
        let interactor = TransactionListInteractor()
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

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


@MainActor
@Observable
class TransactionListViewController: TransactionListViewControllerProtocol {
    var displayedTransactions: [TransactionList.FetchTransactions.ViewModel.DisplayedTransaction] = []
    var isLoading = false
    
    var interactor: TransactionListInteractorProtocol?
    
    // ✅ ViewController doesn't use Services directly
    // Services are injected into Workers
    init(analyticsService: AnalyticsService) {
        setupVIP(analyticsService: analyticsService)
    }
    
    private func setupVIP(analyticsService: AnalyticsService) {
        // ✅ Create Workers with Services
        let networkService = NetworkService()
        let cacheService = CacheService()
        
        let transactionWorker = TransactionWorker(
            networkService: networkService,
            cacheService: cacheService
        )
        
        let analyticsWorker = AnalyticsWorker(
            analyticsService: analyticsService
        )
        
        // ✅ Create Interactor with Workers (not Services)
        let interactor = TransactionListInteractor(
            transactionWorker: transactionWorker,
            analyticsWorker: analyticsWorker
        )
        
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

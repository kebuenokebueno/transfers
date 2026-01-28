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


// MARK: - View (acts as ViewController)

// MARK: - View (acts as ViewController)
@MainActor
@Observable
class TransactionListViewController: TransactionListViewControllerProtocol {
    var displayedTransactions: [TransactionList.FetchTransactions.ViewModel.DisplayedTransaction] = []
    var isLoading = false
    
    // ✅ Add a simple counter to force UI updates
    private(set) var updateTrigger: Int = 0
    
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
        print("🔵 ViewController: loadTransactions() called")
        isLoading = true
        print("🔵 ViewController: isLoading set to true")
        Task {
            print("🔵 ViewController: About to call interactor.fetchTransactions()")
            await interactor?.fetchTransactions()
            print("🔵 ViewController: interactor.fetchTransactions() completed")
            // Note: isLoading will be set to false in displayTransactions()
        }
    }
    
    func displayTransactions(viewModel: TransactionList.FetchTransactions.ViewModel) {
        print("🟢 ViewController: displayTransactions called with \(viewModel.transactions.count) transactions")
        displayedTransactions = viewModel.transactions
        print("🟢 ViewController: displayedTransactions now has \(displayedTransactions.count) items")
        isLoading = false
        print("🟢 ViewController: isLoading set to false")
        
        // ✅ Force SwiftUI to detect the change
        updateTrigger += 1
        print("🟢 ViewController: updateTrigger incremented to \(updateTrigger)")
    }
}

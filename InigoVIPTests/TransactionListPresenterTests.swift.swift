// MARK: - Presenter Tests

import Foundation
import SwiftUI
import Testing
@testable import InigoVIP


@Suite("TransactionList Presenter Tests")
struct TransactionListPresenterTests {
    
    @MainActor
    @Test("Present transactions formats data correctly")
    func presentTransactionsFormatsCorrectly() {
        // Given
        let sut = TransactionListPresenter()
        let mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
        
        let transaction = Transfer(
            id: "1",
            amount: -50.50,
            description: "Test Transaction",
            date: Date(),
            category: "Food"
        )
        let response = TransactionList.FetchTransactions.Response(transactions: [transaction])
        
        // When
        sut.presentTransactions(response: response)
        
        // Then
        #expect(mockViewController.displayTransactionsCalled == true)
        #expect(mockViewController.receivedViewModel?.transactions.count == 1)
        
        let displayedTransaction = mockViewController.receivedViewModel?.transactions.first
        #expect(displayedTransaction?.id == "1")
        #expect(displayedTransaction?.description == "Test Transaction")
        #expect(displayedTransaction?.isPositive == false)
        #expect(displayedTransaction?.amount.contains("50") == true)
    }
    
    @MainActor
    @Test("Present positive transaction shows correct sign")
    func presentPositiveTransaction() {
        // Given
        let sut = TransactionListPresenter()
        let mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
        
        let transaction = Transfer(
            id: "2",
            amount: 2500.00,
            description: "Salary",
            date: Date(),
            category: "Income"
        )
        let response = TransactionList.FetchTransactions.Response(transactions: [transaction])
        
        // When
        sut.presentTransactions(response: response)
        
        // Then
        let displayedTransaction = mockViewController.receivedViewModel?.transactions.first
        #expect(displayedTransaction?.isPositive == true)
        #expect(displayedTransaction?.category == "Income")
    }
    
    @MainActor
    @Test("Present empty transactions list")
    func presentEmptyTransactions() {
        // Given
        let sut = TransactionListPresenter()
        let mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
        
        let response = TransactionList.FetchTransactions.Response(transactions: [])
        
        // When
        sut.presentTransactions(response: response)
        
        // Then
        #expect(mockViewController.displayTransactionsCalled == true)
        #expect(mockViewController.receivedViewModel?.transactions.isEmpty == true)
    }
}

// Helper extension for MockWorker
extension MockTransactionWorker {
    func setShouldFail(_ value: Bool) {
        self.shouldFail = value
    }
}

// MARK: - UI Tests (SwiftUI Preview for manual testing)
struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView()
    }
}

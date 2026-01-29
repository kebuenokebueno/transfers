
import Foundation
import SwiftUI
import Testing
@testable import InigoVIP

// MARK: - Presenter Tests

@Suite("TransactionList Presenter Tests", .tags(.unit, .presenter))
struct TransactionListPresenterTests {
    
    // MARK: - Data Formatting
    
    @MainActor
    @Test("Present transactions formats negative amounts correctly")
    func presentTransactionsFormatsNegativeAmount() {
        // Arrange
        let sut = TransactionListPresenter()
        let mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
        
        let transaction = TestDataBuilder.createTransfer(
            id: "1",
            amount: -50.50,
            description: "Test Transaction",
            category: "Food"
        )
        let response = TransactionList.FetchTransactions.Response(transactions: [transaction])
        
        // Act
        sut.presentTransactions(response: response)
        
        // Assert
        #expect(mockViewController.displayTransactionsCalled == true,
                "ViewController should be called")
        #expect(mockViewController.receivedViewModel?.transactions.count == 1,
                "Should format one transaction")
        
        let displayedTransaction = mockViewController.receivedViewModel?.transactions.first
        #expect(displayedTransaction?.id == "1")
        #expect(displayedTransaction?.description == "Test Transaction")
        #expect(displayedTransaction?.isPositive == false,
                "Negative amount should be marked as expense")
        #expect(displayedTransaction?.amount.contains("50") == true,
                "Amount should contain the value")
        #expect(displayedTransaction?.amount.contains("€") == true,
                "Amount should contain currency symbol")
    }
    
    @MainActor
    @Test("Present transactions formats positive amounts correctly")
    func presentTransactionsFormatsPositiveAmount() {
        // Arrange
        let sut = TransactionListPresenter()
        let mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
        
        let transaction = TestDataBuilder.createTransfer(
            id: "2",
            amount: 2500.00,
            description: "Salary",
            category: "Income"
        )
        let response = TransactionList.FetchTransactions.Response(transactions: [transaction])
        
        // Act
        sut.presentTransactions(response: response)
        
        // Assert
        let displayedTransaction = mockViewController.receivedViewModel?.transactions.first
        #expect(displayedTransaction?.isPositive == true,
                "Positive amount should be marked as income")
        #expect(displayedTransaction?.category == "Income")
        #expect(displayedTransaction?.amount.contains("2") == true)
        #expect(displayedTransaction?.amount.contains("500") == true)
    }
    
    @MainActor
    @Test("Present transactions formats dates correctly")
    func presentTransactionsFormatsDate() {
        // Arrange
        let sut = TransactionListPresenter()
        let mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
        
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2026, month: 1, day: 25))!
        
        let transaction = TestDataBuilder.createTransfer(
            id: "1",
            amount: -100.0,
            date: testDate
        )
        let response = TransactionList.FetchTransactions.Response(transactions: [transaction])
        
        // Act
        sut.presentTransactions(response: response)
        
        // Assert
        let displayedTransaction = mockViewController.receivedViewModel?.transactions.first
        #expect(displayedTransaction?.date.contains("Jan") == true ||
                displayedTransaction?.date.contains("2026") == true,
                "Date should be formatted properly")
    }
    
    @MainActor
    @Test("Present transactions handles empty list")
    func presentEmptyTransactions() {
        // Arrange
        let sut = TransactionListPresenter()
        let mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
        
        let response = TransactionList.FetchTransactions.Response(transactions: [])
        
        // Act
        sut.presentTransactions(response: response)
        
        // Assert
        #expect(mockViewController.displayTransactionsCalled == true,
                "ViewController should be called even with empty list")
        #expect(mockViewController.receivedViewModel?.transactions.isEmpty == true,
                "Should present empty list correctly")
    }
    
    @MainActor
    @Test("Present transactions preserves transaction order")
    func presentTransactionsPreservesOrder() {
        // Arrange
        let sut = TransactionListPresenter()
        let mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
        
        let transactions = [
            TestDataBuilder.createTransfer(id: "1", description: "First"),
            TestDataBuilder.createTransfer(id: "2", description: "Second"),
            TestDataBuilder.createTransfer(id: "3", description: "Third")
        ]
        let response = TransactionList.FetchTransactions.Response(transactions: transactions)
        
        // Act
        sut.presentTransactions(response: response)
        
        // Assert
        let displayed = mockViewController.receivedViewModel?.transactions ?? []
        #expect(displayed.count == 3)
        #expect(displayed[0].id == "1")
        #expect(displayed[0].description == "First")
        #expect(displayed[1].id == "2")
        #expect(displayed[1].description == "Second")
        #expect(displayed[2].id == "3")
        #expect(displayed[2].description == "Third")
    }
    
    // MARK: - Currency Formatting
    
    @MainActor
    @Test("Present transactions uses absolute values for display")
    func presentTransactionsUsesAbsoluteValues() {
        // Arrange
        let sut = TransactionListPresenter()
        let mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
        
        let transaction = TestDataBuilder.createTransfer(
            id: "1",
            amount: -123.45
        )
        let response = TransactionList.FetchTransactions.Response(transactions: [transaction])
        
        // Act
        sut.presentTransactions(response: response)
        
        // Assert
        let displayedAmount = mockViewController.receivedViewModel?.transactions.first?.amount
        #expect(displayedAmount?.contains("-") == false,
                "Displayed amount should not contain minus sign (handled by color)")
        #expect(displayedAmount?.contains("123") == true)
    }
    
    @MainActor
    @Test("Present transactions includes thumbnailUrl when present")
    func presentTransactionsIncludesThumbnailUrl() {
        // Arrange
        let sut = TransactionListPresenter()
        let mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
        
        let transaction = TestDataBuilder.createTransfer(
            id: "1",
            amount: -50.0,
            thumbnailUrl: "https://example.com/image.jpg"
        )
        let response = TransactionList.FetchTransactions.Response(transactions: [transaction])
        
        // Act
        sut.presentTransactions(response: response)
        
        // Assert
        let displayed = mockViewController.receivedViewModel?.transactions.first
        #expect(displayed?.thumbnailUrl == "https://example.com/image.jpg",
                "Should preserve thumbnail URL")
    }
    
    // MARK: - Edge Cases
    
    @MainActor
    @Test("Present transactions handles zero amount")
    func presentTransactionsHandlesZeroAmount() {
        // Arrange
        let sut = TransactionListPresenter()
        let mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
        
        let transaction = TestDataBuilder.createTransfer(id: "1", amount: 0.0)
        let response = TransactionList.FetchTransactions.Response(transactions: [transaction])
        
        // Act
        sut.presentTransactions(response: response)
        
        // Assert
        let displayed = mockViewController.receivedViewModel?.transactions.first
        #expect(displayed?.isPositive == true,
                "Zero amount should be treated as positive")
    }
    
    @MainActor
    @Test("Present transactions handles very large amounts")
    func presentTransactionsHandlesLargeAmounts() {
        // Arrange
        let sut = TransactionListPresenter()
        let mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
        
        let transaction = TestDataBuilder.createTransfer(
            id: "1",
            amount: 1_000_000.99
        )
        let response = TransactionList.FetchTransactions.Response(transactions: [transaction])
        
        // Act
        sut.presentTransactions(response: response)
        
        // Assert
        let displayed = mockViewController.receivedViewModel?.transactions.first
        #expect(displayed?.amount.contains("€") == true,
                "Should format large amounts with currency")
    }
    
    @MainActor
    @Test("Present transactions handles nil viewController gracefully")
    func presentTransactionsWithNilViewController() {
        // Arrange
        let sut = TransactionListPresenter()
        // viewController is nil
        
        let transaction = TestDataBuilder.createTransfer(id: "1", amount: 100.0)
        let response = TransactionList.FetchTransactions.Response(transactions: [transaction])
        
        // Act - should not crash
        sut.presentTransactions(response: response)
        
        // Assert - no crash is success
        #expect(true, "Should handle nil viewController without crashing")
    }
    
    // MARK: - Multiple Calls
    
    @MainActor
    @Test("Present transactions can be called multiple times")
    func presentTransactionsMultipleCalls() {
        // Arrange
        let sut = TransactionListPresenter()
        let mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
        
        let firstBatch = [TestDataBuilder.createTransfer(id: "1", amount: 100.0)]
        let secondBatch = [
            TestDataBuilder.createTransfer(id: "2", amount: 200.0),
            TestDataBuilder.createTransfer(id: "3", amount: 300.0)
        ]
        
        // Act
        sut.presentTransactions(response: TransactionList.FetchTransactions.Response(transactions: firstBatch))
        sut.presentTransactions(response: TransactionList.FetchTransactions.Response(transactions: secondBatch))
        
        // Assert
        #expect(mockViewController.displayTransactionsCallCount == 2,
                "ViewController should be called twice")
        #expect(mockViewController.receivedViewModel?.transactions.count == 2,
                "Should have latest data")
    }
}

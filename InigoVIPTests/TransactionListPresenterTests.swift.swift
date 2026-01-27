//
//  TransactionListPresenterTests.swift.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Testing
@testable import InigoVIP
import XCTest

// MARK: - Presenter Tests
class TransactionListPresenterTests: XCTestCase {
    var sut: TransactionListPresenter!
    var mockViewController: MockTransactionListViewController!
    
    @MainActor
    override func setUp() {
        super.setUp()
        sut = TransactionListPresenter()
        mockViewController = MockTransactionListViewController()
        sut.viewController = mockViewController
    }
    
    override func tearDown() {
        sut = nil
        mockViewController = nil
        super.tearDown()
    }
    
    @MainActor
    func testPresentTransactionsFormatsCorrectly() {
        // Given
        let transaction = Transaction(
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
        XCTAssertTrue(mockViewController.displayTransactionsCalled)
        XCTAssertEqual(mockViewController.receivedViewModel?.transactions.count, 1)
        
        let displayedTransaction = mockViewController.receivedViewModel?.transactions.first
        XCTAssertEqual(displayedTransaction?.id, "1")
        XCTAssertEqual(displayedTransaction?.description, "Test Transaction")
        XCTAssertFalse(displayedTransaction?.isPositive ?? true)
        XCTAssertTrue(displayedTransaction?.amount.contains("50") ?? false)
    }
}

// MARK: - UI Tests (SwiftUI Preview for manual testing)
struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView()
    }
}

// Helper extension for MockWorker
extension MockTransactionWorker {
    func setMockTransactions(_ transactions: [Transaction]) {
        self.mockTransactions = transactions
    }
}

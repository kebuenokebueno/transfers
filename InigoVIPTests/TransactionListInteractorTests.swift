//
//  InigoVIPTests.swift
//  InigoVIPTests
//
//  Created by Inigo on 27/1/26.
//

import Testing
@testable import InigoVIP
import XCTest

// Mock Worker for testing
actor MockTransactionWorker: TransactionWorkerProtocol {
    var shouldFail = false
    var mockTransactions: [Transaction] = []
    
    func fetchTransactions() async throws -> [Transaction] {
        if shouldFail {
            throw NSError(domain: "test", code: -1)
        }
        return mockTransactions
    }
}

// Mock Presenter for testing Interactor
@MainActor
class MockTransactionListPresenter: TransactionListPresenterProtocol {
    var presentTransactionsCalled = false
    var receivedResponse: TransactionList.FetchTransactions.Response?
    
    func presentTransactions(response: TransactionList.FetchTransactions.Response) {
        presentTransactionsCalled = true
        receivedResponse = response
    }
}

// Mock ViewController for testing Presenter
@MainActor
class MockTransactionListViewController: TransactionListViewControllerProtocol {
    var displayTransactionsCalled = false
    var receivedViewModel: TransactionList.FetchTransactions.ViewModel?
    
    func displayTransactions(viewModel: TransactionList.FetchTransactions.ViewModel) {
        displayTransactionsCalled = true
        receivedViewModel = viewModel
    }
}

// MARK: - Interactor Tests
class TransactionListInteractorTests: XCTestCase {
    var sut: TransactionListInteractor!
    var mockWorker: MockTransactionWorker!
    var mockPresenter: MockTransactionListPresenter!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockWorker = MockTransactionWorker()
        sut = TransactionListInteractor(worker: mockWorker)
        mockPresenter = MockTransactionListPresenter()
        sut.presenter = mockPresenter
    }
    
    override func tearDown() {
        sut = nil
        mockWorker = nil
        mockPresenter = nil
        super.tearDown()
    }
    
    @MainActor
    func testFetchTransactionsSuccess() async {
        // Given
        let expectedTransactions = [
            Transaction(id: "1", amount: 100, description: "Test", date: Date(), category: "Test")
        ]
        await mockWorker.setMockTransactions(expectedTransactions)
        
        // When
        await sut.fetchTransactions()
        
        // Then
        XCTAssertTrue(mockPresenter.presentTransactionsCalled)
        XCTAssertEqual(mockPresenter.receivedResponse?.transactions.count, 1)
        XCTAssertEqual(mockPresenter.receivedResponse?.transactions.first?.id, "1")
    }
}

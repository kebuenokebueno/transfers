// MARK: - Unit Tests with Swift Testing
import Testing
import SwiftUI
@testable import InigoVIP


// Mock Worker for testing
actor MockTransactionWorker: TransactionWorkerProtocol {
    var shouldFail = false
    var mockTransactions: [Transfer] = []
    
    func fetchTransactions() async throws -> [Transfer] {
        if shouldFail {
            throw NSError(domain: "test", code: -1)
        }
        return mockTransactions
    }
    
    func setMockTransactions(_ transactions: [Transfer]) {
        self.mockTransactions = transactions
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
@Suite("TransactionList Interactor Tests")
struct TransactionListInteractorTests {
    
    @MainActor
    @Test("Fetch transactions successfully")
    func fetchTransactionsSuccess() async throws {
        // Given
        let mockWorker = MockTransactionWorker()
        let sut = TransactionListInteractor(worker: mockWorker)
        let mockPresenter = MockTransactionListPresenter()
        sut.presenter = mockPresenter
        
        let expectedTransactions = [
            Transfer(id: "1", amount: 100, description: "Test", date: Date(), category: "Test")
        ]
        await mockWorker.setMockTransactions(expectedTransactions)
        
        // When
        await sut.fetchTransactions()
        
        // Then
        #expect(mockPresenter.presentTransactionsCalled == true)
        #expect(mockPresenter.receivedResponse?.transactions.count == 1)
        #expect(mockPresenter.receivedResponse?.transactions.first?.id == "1")
    }
    
    @MainActor
    @Test("Fetch transactions handles error gracefully")
    func fetchTransactionsHandlesError() async throws {
        // Given
        let mockWorker = MockTransactionWorker()
        await mockWorker.setShouldFail(true)
        
        let sut = TransactionListInteractor(worker: mockWorker)
        let mockPresenter = MockTransactionListPresenter()
        sut.presenter = mockPresenter
        
        // When
        await sut.fetchTransactions()
        
        // Then
        #expect(mockPresenter.presentTransactionsCalled == false)
    }
}

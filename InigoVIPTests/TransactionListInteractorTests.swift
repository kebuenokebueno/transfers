// MARK: - Unit Tests with Swift Testing
import Testing
import SwiftUI
@testable import InigoVIP


// Mock Analytics Worker for testing
actor MockAnalyticsWorker: AnalyticsWorkerProtocol {
    var trackedEvents: [String] = []
    
    func trackEvent(_ event: String) async {
        trackedEvents.append(event)
    }
    
    func trackScreenView(_ screenName: String) async {
        trackedEvents.append("screen_view: \(screenName)")
    }
}


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
    
    func setShouldFail(_ value: Bool) {
        self.shouldFail = value
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
        let mockAnalyticsWorker = MockAnalyticsWorker()
        let sut = TransactionListInteractor(
            transactionWorker: mockWorker,
            analyticsWorker: mockAnalyticsWorker
        )
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
        
        let mockAnalyticsWorker = MockAnalyticsWorker()
        let sut = TransactionListInteractor(
            transactionWorker: mockWorker,
            analyticsWorker: mockAnalyticsWorker
        )
        let mockPresenter = MockTransactionListPresenter()
        sut.presenter = mockPresenter
        
        // When
        await sut.fetchTransactions()
        
        // Then
        #expect(mockPresenter.presentTransactionsCalled == false)
    }
}

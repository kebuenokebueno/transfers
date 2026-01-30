//
//  MockClasses.swift
//  InigoVIPTests
//
//  Created by Inigo on 29/1/26.
//

import Foundation
import Testing


extension Tag {
    @Tag static var unit: Self
    @Tag static var interactor: Self
    @Tag static var presenter: Self
    @Tag static var integration: Self
    @Tag static var performance: Self
    @Tag static var network: Self
}


actor MockNetworkService: NetworkServiceProtocol {
    
    var shouldFail = false
    var delayMilliseconds: UInt64 = 0  // Simulate network delay if needed
    var mockResponse: [Transfer] = []
    var callCount = 0
    
    
    static func successResponse() -> [Transfer] {
        return TestDataBuilder.createMixedTransfers()
    }
    
    // MARK: - Mock Implementation
    
    func fetchTransactions() async throws -> [Transfer] {
        callCount += 1
        
        // Simulate network delay if configured
        if delayMilliseconds > 0 {
            try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        }
        
        // Simulate network error
        if shouldFail {
            throw NetworkError.connectionFailed
        }
        
        // Return mock data (instant, no network) ✅
        return mockResponse
    }
    
    // MARK: - Test Helpers
    
    func setSuccessResponse() async {
        mockResponse = Self.successResponse()
        shouldFail = false
    }
    
    static func emptyResponse() -> [Transfer] {
        []
    }
    
    static func largeResponse(count: Int = 1000) -> [Transfer] {
        (1...count).map { index in
            Transfer(
                id: "\(index)",
                amount: Double.random(in: -200...2000),
                description: "Transaction \(index)",
                date: Date(),
                category: ["Food", "Utilities", "Income", "Transport"][index % 4],
                thumbnailUrl: "https://example.com/image\(index).jpg"
            )
        }
    }
    
    func setDelay(milliseconds: UInt64) async {
        delayMilliseconds = milliseconds
    }
    
    func setEmptyResponse() async {
        mockResponse = Self.emptyResponse()
        shouldFail = false
    }
    
    func setLargeResponse(count: Int = 1000) async {
        mockResponse = Self.largeResponse(count: count)
        shouldFail = false
    }
    
    func setFailure() async {
        shouldFail = true
    }
    
    func reset() async {
        mockResponse = []
        shouldFail = false
        delayMilliseconds = 0
        callCount = 0
    }

}

// MARK: - Mock Objects

/// Mock Worker for testing - Conforms to TransactionWorkerProtocol
actor MockTransactionWorker: TransactionWorkerProtocol {
    var shouldFail = false
    var mockTransactions: [Transfer] = []
    var fetchCallCount = 0
    var lastFetchTimestamp: Date?
    
    func fetchTransactions() async throws -> [Transfer] {
        fetchCallCount += 1
        lastFetchTimestamp = Date()
        
        if shouldFail {
            throw NetworkError.connectionFailed
        }
        return mockTransactions
    }
    
    func setMockTransactions(_ transactions: [Transfer]) async {
        self.mockTransactions = transactions
    }
    
    func setShouldFail(_ value: Bool) async {
        self.shouldFail = value
    }
}

/// Mock Analytics Worker - Tracks all events
actor MockAnalyticsWorker: AnalyticsWorkerProtocol {
    var trackedEvents: [String] = []
    var screenViews: [String] = []
    
    func trackEvent(_ event: String) async {
        trackedEvents.append(event)
    }
    
    func trackScreenView(_ screenName: String) async {
        screenViews.append(screenName)
        trackedEvents.append("screen_view: \(screenName)")
    }
}

/// Mock Presenter for testing Interactor
@MainActor
class MockTransactionListPresenter: TransactionListPresenterProtocol {
    var presentTransactionsCalled = false
    var presentTransactionsCallCount = 0
    var receivedResponse: TransactionList.FetchTransactions.Response?
    var allReceivedResponses: [TransactionList.FetchTransactions.Response] = []
    
    func presentTransactions(response: TransactionList.FetchTransactions.Response) {
        presentTransactionsCalled = true
        presentTransactionsCallCount += 1
        receivedResponse = response
        allReceivedResponses.append(response)
    }
}

/// Mock ViewController for testing Presenter
@MainActor
class MockTransactionListViewController: TransactionListViewControllerProtocol {
    var displayTransactionsCalled = false
    var displayTransactionsCallCount = 0
    var receivedViewModel: TransactionList.FetchTransactions.ViewModel?
    var allReceivedViewModels: [TransactionList.FetchTransactions.ViewModel] = []
    
    func displayTransactions(viewModel: TransactionList.FetchTransactions.ViewModel) {
        displayTransactionsCalled = true
        displayTransactionsCallCount += 1
        receivedViewModel = viewModel
        allReceivedViewModels.append(viewModel)
    }
}

// MARK: - Test Data Builders

struct TestDataBuilder {
    /// Creates a sample transfer for testing
    static func createTransfer(
        id: String = "test_1",
        amount: Double = 100.0,
        description: String = "Test Transaction",
        date: Date = Date(),
        category: String = "Test",
        thumbnailUrl: String? = nil
    ) -> Transfer {
        Transfer(
            id: id,
            amount: amount,
            description: description,
            date: date,
            category: category,
            thumbnailUrl: thumbnailUrl
        )
    }
    
    /// Creates multiple test transfers
    static func createTransfers(count: Int) -> [Transfer] {
        (1...count).map { index in
            createTransfer(
                id: "test_\(index)",
                amount: Double(index) * 10.0,
                description: "Transaction \(index)",
                category: ["Food", "Utilities", "Income", "Transport"][index % 4]
            )
        }
    }
    
    /// Creates a mix of income and expense transfers
    static func createMixedTransfers() -> [Transfer] {
        [
            createTransfer(id: "1", amount: -45.50, description: "Grocery Store", category: "Food"),
            createTransfer(id: "2", amount: -120.00, description: "Electric Bill", category: "Utilities"),
            createTransfer(id: "3", amount: 2500.00, description: "Salary", category: "Income"),
            createTransfer(id: "4", amount: -30.00, description: "Gas", category: "Transport"),
            createTransfer(id: "5", amount: 150.00, description: "Freelance", category: "Income")
        ]
    }
}

// MARK: - Custom Error Types

enum NetworkError: Error, Equatable {
    case connectionFailed
    case timeout
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError
}

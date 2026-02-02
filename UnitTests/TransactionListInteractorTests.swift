
// File: TransactionListTests.swift
// Coverage Target: 85%+
// Framework: Swift Testing (iOS 17+)

import Testing
import Foundation
import SwiftUI
@testable import InigoVIP


// MARK: - Interactor Tests

@Suite("TransactionList Interactor Tests", .tags(.unit, .interactor))
struct TransactionListInteractorTests {
    
    // MARK: - Success Cases
    
    @Test("Worker uses network service")
    func testWorkerUsesNetwork() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        await mockNetwork.setSuccessResponse()
        
        let worker = TransactionWorker(networkService: mockNetwork)
        
        // Act
        let transactions = try await worker.fetchTransactions()
        
        // Assert
        #expect(transactions.count == 5)
        #expect(transactions[0].description == "Grocery Store")
        
        // Verify network was called
        let callCount = await mockNetwork.callCount
        #expect(callCount == 1, "Network should be called once")
    }

    @Test("Worker uses cache to avoid network calls")
    func testWorkerUsesCache() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        await mockNetwork.setSuccessResponse()
        let cacheService = CacheService()
        
        let worker = TransactionWorker(
            networkService: mockNetwork,
            cacheService: cacheService
        )
        
        // Act - First call hits network
        _ = try await worker.fetchTransactions()
        
        // Second call should use cache
        _ = try await worker.fetchTransactions()
        
        // Assert
        let callCount = await mockNetwork.callCount
        #expect(callCount == 1, "Network should only be called once (cache used for 2nd call)")
    }
    
    
    @MainActor
    @Test("Fetch transactions successfully with valid data")
    func fetchTransactionsSuccess() async throws {
        // Arrange
        let mockWorker = MockTransactionWorker()
        let mockAnalyticsWorker = MockAnalyticsWorker()
        let sut = TransactionListInteractor(
            transactionWorker: mockWorker,
            analyticsWorker: mockAnalyticsWorker
        )
        let mockPresenter = MockTransactionListPresenter()
        sut.presenter = mockPresenter
        
        let expectedTransactions = TestDataBuilder.createMixedTransfers()
        await mockWorker.setMockTransactions(expectedTransactions)
        
        // Act
        await sut.fetchTransactions()
        
        // Assert
        #expect(mockPresenter.presentTransactionsCalled == true,
                "Presenter should be called after successful fetch")
        #expect(mockPresenter.receivedResponse?.transactions.count == 5,
                "Should receive all 5 transactions")
        #expect(mockPresenter.presentTransactionsCallCount == 1,
                "Presenter should be called exactly once")
        
        // Verify transaction data integrity
        let firstTransaction = mockPresenter.receivedResponse?.transactions.first
        #expect(firstTransaction?.id == "1")
        #expect(firstTransaction?.amount == -45.50)
        #expect(firstTransaction?.description == "Grocery Store")
    }
    
    @MainActor
    @Test("Fetch transactions with empty result")
    func fetchTransactionsEmpty() async throws {
        // Arrange
        let mockWorker = MockTransactionWorker()
        let mockAnalyticsWorker = MockAnalyticsWorker()
        let sut = TransactionListInteractor(
            transactionWorker: mockWorker,
            analyticsWorker: mockAnalyticsWorker
        )
        let mockPresenter = MockTransactionListPresenter()
        sut.presenter = mockPresenter
        
        await mockWorker.setMockTransactions([])
        
        // Act
        await sut.fetchTransactions()
        
        // Assert
        #expect(mockPresenter.presentTransactionsCalled == true,
                "Presenter should be called even with empty results")
        #expect(mockPresenter.receivedResponse?.transactions.isEmpty == true,
                "Should handle empty transaction list")
    }
    
    @MainActor
    @Test("Fetch transactions with large dataset (1000 items)")
    func fetchTransactionsLargeDataset() async throws {
        // Arrange
        let mockWorker = MockTransactionWorker()
        let mockAnalyticsWorker = MockAnalyticsWorker()
        let sut = TransactionListInteractor(
            transactionWorker: mockWorker,
            analyticsWorker: mockAnalyticsWorker
        )
        let mockPresenter = MockTransactionListPresenter()
        sut.presenter = mockPresenter
        
        let largeDataset = TestDataBuilder.createTransfers(count: 1000)
        await mockWorker.setMockTransactions(largeDataset)
        
        // Act
        await sut.fetchTransactions()
        
        // Assert
        #expect(mockPresenter.receivedResponse?.transactions.count == 1000,
                "Should handle large datasets")
    }
    
    // MARK: - Error Handling
    
    @MainActor
    @Test("Fetch transactions handles network error gracefully")
    func fetchTransactionsHandlesError() async throws {
        // Arrange
        let mockWorker = MockTransactionWorker()
        await mockWorker.setShouldFail(true)
        
        let mockAnalyticsWorker = MockAnalyticsWorker()
        let sut = TransactionListInteractor(
            transactionWorker: mockWorker,
            analyticsWorker: mockAnalyticsWorker
        )
        let mockPresenter = MockTransactionListPresenter()
        sut.presenter = mockPresenter
        
        // Act
        await sut.fetchTransactions()
        
        // Assert
        #expect(mockPresenter.presentTransactionsCalled == false,
                "Presenter should not be called when error occurs")
        #expect(mockPresenter.presentTransactionsCallCount == 0,
                "Presenter call count should be zero on error")
    }
    
    @MainActor
    @Test("Fetch transactions handles nil presenter gracefully")
    func fetchTransactionsWithNilPresenter() async throws {
        // Arrange
        let mockWorker = MockTransactionWorker()
        let mockAnalyticsWorker = MockAnalyticsWorker()
        let sut = TransactionListInteractor(
            transactionWorker: mockWorker,
            analyticsWorker: mockAnalyticsWorker
        )
        // Note: presenter is nil
        
        let transactions = TestDataBuilder.createMixedTransfers()
        await mockWorker.setMockTransactions(transactions)
        
        // Act - should not crash
        await sut.fetchTransactions()
        
        // Assert - no crash is the success criteria
        #expect(true, "Should handle nil presenter without crashing")
    }
    
    // MARK: - Analytics Tracking
    
    @MainActor
    @Test("Fetch transactions tracks analytics events")
    func fetchTransactionsTracksAnalytics() async throws {
        // Arrange
        let mockWorker = MockTransactionWorker()
        let mockAnalyticsWorker = MockAnalyticsWorker()
        let sut = TransactionListInteractor(
            transactionWorker: mockWorker,
            analyticsWorker: mockAnalyticsWorker
        )
        let mockPresenter = MockTransactionListPresenter()
        sut.presenter = mockPresenter
        
        let transactions = TestDataBuilder.createTransfers(count: 3)
        await mockWorker.setMockTransactions(transactions)
        
        // Act
        await sut.fetchTransactions()
        
        // Assert
        let events = await mockAnalyticsWorker.trackedEvents
        #expect(events.contains(where: { $0.contains("fetch_transactions_started") }),
                "Should track fetch start event")
        #expect(events.contains(where: { $0.contains("fetch_transactions_success") }),
                "Should track fetch success event")
        #expect(events.contains(where: { $0.contains("3 items") }),
                "Should include item count in analytics")
    }
    
    @MainActor
    @Test("Fetch transactions does not track success on error")
    func fetchTransactionsDoesNotTrackSuccessOnError() async throws {
        // Arrange
        let mockWorker = MockTransactionWorker()
        await mockWorker.setShouldFail(true)
        let mockAnalyticsWorker = MockAnalyticsWorker()
        let sut = TransactionListInteractor(
            transactionWorker: mockWorker,
            analyticsWorker: mockAnalyticsWorker
        )
        
        // Act
        await sut.fetchTransactions()
        
        // Assert
        let events = await mockAnalyticsWorker.trackedEvents
        #expect(events.contains(where: { $0.contains("fetch_transactions_started") }),
                "Should track start event even on error")
        #expect(!events.contains(where: { $0.contains("fetch_transactions_success") }),
                "Should not track success event on error")
    }
    
    // MARK: - Worker Integration
    
    @MainActor
    @Test("Fetch transactions calls worker exactly once")
    func fetchTransactionsCallsWorkerOnce() async throws {
        // Arrange
        let mockWorker = MockTransactionWorker()
        let mockAnalyticsWorker = MockAnalyticsWorker()
        let sut = TransactionListInteractor(
            transactionWorker: mockWorker,
            analyticsWorker: mockAnalyticsWorker
        )
        let mockPresenter = MockTransactionListPresenter()
        sut.presenter = mockPresenter
        
        await mockWorker.setMockTransactions(TestDataBuilder.createTransfers(count: 2))
        
        // Act
        await sut.fetchTransactions()
        
        // Assert
        let callCount = await mockWorker.fetchCallCount
        #expect(callCount == 1, "Worker should be called exactly once")
    }
    
    @MainActor
    @Test("Multiple fetch calls work correctly")
    func multipleFetchCalls() async throws {
        // Arrange
        let mockWorker = MockTransactionWorker()
        let mockAnalyticsWorker = MockAnalyticsWorker()
        let sut = TransactionListInteractor(
            transactionWorker: mockWorker,
            analyticsWorker: mockAnalyticsWorker
        )
        let mockPresenter = MockTransactionListPresenter()
        sut.presenter = mockPresenter
        
        let firstBatch = TestDataBuilder.createTransfers(count: 3)
        await mockWorker.setMockTransactions(firstBatch)
        
        // Act - First fetch
        await sut.fetchTransactions()
        
        // Update data
        let secondBatch = TestDataBuilder.createTransfers(count: 5)
        await mockWorker.setMockTransactions(secondBatch)
        
        // Act - Second fetch
        await sut.fetchTransactions()
        
        // Assert
        #expect(mockPresenter.presentTransactionsCallCount == 2,
                "Should handle multiple fetch calls")
        #expect(mockPresenter.receivedResponse?.transactions.count == 5,
                "Should have latest data")
        
        let workerCalls = await mockWorker.fetchCallCount
        #expect(workerCalls == 2, "Worker should be called twice")
    }
}

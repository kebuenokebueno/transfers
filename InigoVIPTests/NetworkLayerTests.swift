//
//  NetworkLayerTests.swift
//  InigoVIP
//
//  Created by Inigo on 29/1/26.
//

import Testing
import Foundation
import SwiftUI
@testable import InigoVIP

@Suite("Network Layer Tests - Offline", .tags(.unit, .network))
struct NetworkLayerTests {
    
    // MARK: - Success Cases
    
    @Test("Fetch transactions returns valid data")
    func fetchTransactionsSuccess() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        await mockNetwork.setSuccessResponse()
        
        // Act
        let transactions = try await mockNetwork.fetchTransactions()
        
        // Assert
        #expect(transactions.count == 5, "Should return 5 mock transactions")
        #expect(transactions[0].description == "Grocery Store")
        #expect(transactions[1].amount == -120.00)
        #expect(transactions[2].category == "Income")
        
        // Verify it was called
        let calls = await mockNetwork.callCount
        #expect(calls == 1, "Should be called exactly once")
    }
    
    @Test("Fetch transactions handles empty response")
    func fetchTransactionsEmpty() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        await mockNetwork.setEmptyResponse()
        
        // Act
        let transactions = try await mockNetwork.fetchTransactions()
        
        // Assert
        #expect(transactions.isEmpty, "Should handle empty response")
    }
    
    @Test("Fetch transactions handles large dataset quickly")
    func fetchTransactionsLargeDataset() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        await mockNetwork.setLargeResponse(count: 5000)
        
        let startTime = Date()
        
        // Act
        let transactions = try await mockNetwork.fetchTransactions()
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Assert
        #expect(transactions.count == 5000)
        #expect(duration < 0.1, "Should be instant without network - got \(duration)s")
        // ✅ With mock: <0.001 seconds
        // ❌ With real API: 5-10 seconds + rate limiting
    }
    
    // MARK: - Error Cases
    
    @Test("Fetch transactions throws error on network failure")
    func fetchTransactionsNetworkError() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        await mockNetwork.setFailure()
        
        // Act & Assert
        do {
            _ = try await mockNetwork.fetchTransactions()
            #expect(Bool(false), "Should throw error")
        } catch {
            #expect(error is NetworkError, "Should throw NetworkError")
        }
    }
    
    @Test("Fetch transactions can retry after failure")
    func fetchTransactionsRetry() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        await mockNetwork.setFailure()
        
        // Act - First attempt fails
        do {
            _ = try await mockNetwork.fetchTransactions()
            #expect(Bool(false), "First call should fail")
        } catch {
            // Expected
        }
        
        // Recover and try again
        await mockNetwork.setSuccessResponse()
        let transactions = try await mockNetwork.fetchTransactions()
        
        // Assert
        #expect(transactions.count == 5, "Should succeed on retry")
        
        let calls = await mockNetwork.callCount
        #expect(calls == 2, "Should track both calls")
    }
    
    // MARK: - Performance
    
    @Test("Mock network is faster than 10ms")
    func mockNetworkPerformance() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        await mockNetwork.setSuccessResponse()
        
        // Act
        let startTime = Date()
        _ = try await mockNetwork.fetchTransactions()
        let duration = Date().timeIntervalSince(startTime)
        
        // Assert
        #expect(duration < 0.01, "Mock should be <10ms, was \(duration * 1000)ms")
        // ✅ Typical: <1ms
        // ❌ Real API: 500-2000ms
    }
    
    @Test("Can simulate network delay for realistic testing")
    func simulateNetworkDelay() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        await mockNetwork.setSuccessResponse()
        await mockNetwork.setDelay(milliseconds: 100)  // ✅ Uses async method
        
        // Act
        let startTime = Date()
        _ = try await mockNetwork.fetchTransactions()
        let duration = Date().timeIntervalSince(startTime)
        
        // Assert
        #expect(duration >= 0.1, "Should respect simulated delay")
        #expect(duration < 0.2, "Should not be too slow")
    }
}

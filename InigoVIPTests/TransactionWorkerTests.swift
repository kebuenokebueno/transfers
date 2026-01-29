//
//  TransactionWorkerTests.swift
//  InigoVIPTests
//
//  Created by Inigo on 29/1/26.
//

import Foundation
import Testing


@Suite("TransactionWorker with Mock Network", .tags(.unit, .integration))
struct TransactionWorkerWithMockNetworkTests {
    
    @Test("TransactionWorker uses mock network service")
    func workerWithMockNetwork() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        await mockNetwork.setSuccessResponse()
        
        // Create worker with mock network
        let worker = TransactionWorker(networkService: mockNetwork)
        
        // Act
        let transactions = try await worker.fetchTransactions()
        
        // Assert
        #expect(transactions.count == 5)
        
        // Verify network was called
        let calls = await mockNetwork.callCount
        #expect(calls == 1)
    }
    
    @Test("Worker handles network errors gracefully")
    func workerHandlesNetworkError() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        await mockNetwork.setFailure()
        
        let worker = TransactionWorker(networkService: mockNetwork)
        
        // Act & Assert
        do {
            _ = try await worker.fetchTransactions()
            #expect(Bool(false), "Should throw error")
        } catch {
            #expect(error is NetworkError)
        }
    }
}

//
//  Untitled.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation


protocol TransactionWorkerProtocol: Sendable {
    func fetchTransactions() async throws -> [Transfer]
}


actor TransactionWorker: TransactionWorkerProtocol {
    let networkService: NetworkServiceProtocol  // ← Use protocol instead of concrete type
    private let swiftDataService: SwiftDataService

    init(networkService: NetworkServiceProtocol = NetworkService(),  // ← Default to real
         swiftDataService: SwiftDataService) {
        self.networkService = networkService
        self.swiftDataService = swiftDataService
    }
    
    func fetchTransactions() async throws -> [Transfer] {
        // Try local first (offline-first)
        let localTransactions = try await swiftDataService.fetchTransactions()
        
        if !localTransactions.isEmpty {
            return localTransactions
        }
        
        // Fetch from API if local is empty
        let remoteTransactions = try await networkService.fetchTransactions()
        
        // Save to local database
        for transaction in remoteTransactions {
            try await swiftDataService.saveTransaction(transaction)
        }
        
        return remoteTransactions
    }
}

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
    // ✅ Worker consume Services
    let networkService: NetworkService
    let cacheService: CacheService
    
    init(networkService: NetworkService = NetworkService(),
         cacheService: CacheService = CacheService()) {
        self.networkService = networkService
        self.cacheService = cacheService
    }
    
    func fetchTransactions() async throws -> [Transfer] {
        // Check cache first
        if let cached: [Transfer] = await cacheService.get(key: "transactions") {
            return cached
        }
        
        // Simulate API call using NetworkService
        let transactions = try await networkService.fetchTransactions()
        
        // Save to cache
        await cacheService.set(key: "transactions", value: transactions)
        
        return transactions
    }
}

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
    let cacheService: CacheService
    
    init(networkService: NetworkServiceProtocol = NetworkService(),  // ← Default to real
         cacheService: CacheService = CacheService()) {
        self.networkService = networkService
        self.cacheService = cacheService
    }
    
    func fetchTransactions() async throws -> [Transfer] {
        // Check cache first
        if let cached: [Transfer] = await cacheService.get(key: "transactions") {
            print("📦 TransactionWorker: Cache hit")
            return cached
        }
        
        print("🌐 TransactionWorker: Fetching from network")
        let transactions = try await networkService.fetchTransactions()  // ← Uses protocol
        
        // Cache results
        await cacheService.set(key: "transactions", value: transactions)
        
        return transactions
    }
}

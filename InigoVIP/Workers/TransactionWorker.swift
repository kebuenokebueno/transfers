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
    func fetchTransactions() async throws -> [Transfer] {
        // Simulate API call
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return [
            Transfer(
                id: "1",
                amount: -45.50,
                description: "Grocery Store",
                date: formatter.date(from: "2026-01-25")!,
                category: "Food"
            ),
            Transfer(
                id: "2",
                amount: -120.00,
                description: "Electric Bill",
                date: formatter.date(from: "2026-01-24")!,
                category: "Utilities"
            ),
            Transfer(
                id: "3",
                amount: 2500.00,
                description: "Salary",
                date: formatter.date(from: "2026-01-20")!,
                category: "Income"
            )
        ]
    }
}

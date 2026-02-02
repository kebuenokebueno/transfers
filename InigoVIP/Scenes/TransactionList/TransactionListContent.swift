//
//  TransactionListContent.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import Foundation
import SwiftUI

struct TransactionListContent: View {
    let transactions: [TransactionList.FetchTransactions.ViewModel.DisplayedTransaction]
    let analyticsService: AnalyticsService
    @Environment(Router.self) private var router
    
    // ✅ Assistive Access: Simplify interaction
    @Environment(\.accessibilityEnabled) private var accessibilityEnabled
    
    var body: some View {
        List {
            ForEach(transactions) { transaction in
                TransactionRow(transaction: transaction)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        analyticsService.trackButtonTap("transaction_\(transaction.id)")
                        // Navigate to detail view with just the ID
                        router.navigate(to: .transactionDetail(id: transaction.id))
                    }
                    // ✅ VoiceOver: Combine elements for cleaner navigation
                    .accessibilityElement(children: .combine)
                    // ✅ VoiceOver: Rich accessibility label
                    .accessibilityLabel(transactionAccessibilityLabel(transaction))
                    // ✅ VoiceOver: Action hint
                    .accessibilityHint("Double tap to view transaction details")
                    // ✅ VoiceControl: Named command
                    .accessibilityIdentifier("transaction_\(transaction.id)")
                    // ✅ VoiceOver: Add action for alternative interaction
                    .accessibilityAction(named: "View Details") {
                        router.navigate(to: .transactionDetail(id: transaction.id))
                    }
            }
        }
        // ✅ VoiceOver: Announce list context
        .accessibilityLabel("Transaction List")
        .accessibilityHint("List of \(transactions.count) transactions")
    }
    
    // ✅ Accessibility Helper: Create natural language labels
    private func transactionAccessibilityLabel(_ transaction: TransactionList.FetchTransactions.ViewModel.DisplayedTransaction) -> String {
        let amountType = transaction.isPositive ? "income" : "expense"
        return "\(transaction.description), \(transaction.amount) \(amountType), \(transaction.category), \(transaction.date)"
    }
}

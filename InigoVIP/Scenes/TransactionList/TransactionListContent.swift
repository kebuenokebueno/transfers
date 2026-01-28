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
    
    @State private var selectedTransaction: TransactionList.FetchTransactions.ViewModel.DisplayedTransaction?
    @State private var showingEditSheet = false
    
    // ✅ Assistive Access: Simplify interaction
    @Environment(\.accessibilityEnabled) private var accessibilityEnabled
    
    var body: some View {
        List {
            ForEach(transactions) { transaction in
                TransactionRow(transaction: transaction)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        analyticsService.trackButtonTap("transaction_\(transaction.id)")
                        selectedTransaction = transaction
                        showingEditSheet = true
                    }
                    // ✅ VoiceOver: Combine elements for cleaner navigation
                    .accessibilityElement(children: .combine)
                    // ✅ VoiceOver: Rich accessibility label
                    .accessibilityLabel(transactionAccessibilityLabel(transaction))
                    // ✅ VoiceOver: Action hint
                    .accessibilityHint("Double tap to edit transaction")
                    // ✅ VoiceControl: Named command
                    .accessibilityIdentifier("transaction_\(transaction.id)")
                    // ✅ VoiceOver: Add action for alternative interaction
                    .accessibilityAction(named: "Edit Transaction") {
                        selectedTransaction = transaction
                        showingEditSheet = true
                    }
            }
        }
        // ✅ VoiceOver: Announce list context
        .accessibilityLabel("Transaction List")
        .accessibilityHint("List of \(transactions.count) transactions")
        .sheet(isPresented: $showingEditSheet) {
            if let transaction = selectedTransaction {
                TransactionEditView(
                    description: transaction.description,
                    amount: transaction.amount,
                    category: transaction.category
                )
            }
        }
    }
    
    // ✅ Accessibility Helper: Create natural language labels
    private func transactionAccessibilityLabel(_ transaction: TransactionList.FetchTransactions.ViewModel.DisplayedTransaction) -> String {
        let amountType = transaction.isPositive ? "income" : "expense"
        return "\(transaction.description), \(transaction.amount) \(amountType), \(transaction.category), \(transaction.date)"
    }
}

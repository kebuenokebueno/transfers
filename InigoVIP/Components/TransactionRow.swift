//
//  TransactionRow.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import SwiftUI


struct TransactionRow: View {
    let transaction: TransactionList.FetchTransactions.ViewModel.DisplayedTransaction
    @State private var showEditSheet = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.headline)
                    .accessibilityIdentifier("transactionDescription")
                
                Text(transaction.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("transactionDate")
                
                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("transactionCategory")
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                (Text(transaction.isPositive ? "+" : "-") + Text(transaction.amount))
                    .foregroundColor(transaction.isPositive ? .green : .red)
                    .font(.headline)
                    .accessibilityIdentifier("transactionAmount")
                
                Button(action: { showEditSheet = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showEditSheet) {
            EditTransactionView(
                description: transaction.description,
                amount: transaction.amount,
                category: transaction.category
            )
        }
    }
}

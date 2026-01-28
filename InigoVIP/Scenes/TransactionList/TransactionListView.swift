//
//  TransactionListView.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import SwiftUI

struct TransactionListView: View {
    @State private var viewController = TransactionListViewController()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewController.isLoading {
                    ProgressView()
                        .accessibilityIdentifier("loadingIndicator")
                } else {
                    List(viewController.displayedTransactions) { transaction in
                        TransactionRow(transaction: transaction)
                            .accessibilityIdentifier("transactionRow_\(transaction.id)")
                    }
                    .accessibilityIdentifier("transactionsList")
                }
            }
            .navigationTitle("Transactions")
            .onAppear {
                viewController.loadTransactions()
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: TransactionList.FetchTransactions.ViewModel.DisplayedTransaction
    
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
            
            Text("\(transaction.isPositive ? "+" : "-")\(transaction.amount)")
                .foregroundColor(transaction.isPositive ? .green : .red)
                .font(.headline)
                .accessibilityIdentifier("transactionAmount")
        }
        .padding(.vertical, 4)
    }
}

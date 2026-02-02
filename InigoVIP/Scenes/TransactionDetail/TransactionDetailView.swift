//
//  TransactionDetailView.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import SwiftUI


struct TransactionDetailView: View {
    let transactionId: String
    @Environment(Router.self) private var router
    @Environment(AnalyticsService.self) private var analyticsService
    @State private var transaction: Transfer?
    
    var body: some View {
        ScrollView {
            if let transaction = transaction {
                VStack(spacing: 24) {
                    // Amount Display
                    Text(transaction.isPositive ? "+€\(String(format: "%.2f", transaction.amount))" : "-€\(String(format: "%.2f", abs(transaction.amount)))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(transaction.isPositive ? .green : .primary)
                    
                    // Category Badge
                    Text(transaction.category)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(20)
                    
                    Divider()
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(label: "Description", value: transaction.description)
                        DetailRow(label: "Date", value: transaction.date.formatted(date: .long, time: .omitted))
                        DetailRow(label: "ID", value: transaction.id)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    // Edit Button
                    Button {
                        analyticsService.trackButtonTap("edit_transaction")
                        router.navigate(to: .editTransaction(id: transaction.id))
                    } label: {
                        Label("Edit Transaction", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Edit this transaction")
                }
                .padding()
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // TODO: Fetch transaction from a service/worker
            // For now, create a placeholder
            transaction = Transfer(
                id: transactionId,
                amount: -50.0,
                description: "Transaction \(transactionId)",
                date: Date(),
                category: "Food",
                thumbnailUrl: nil
            )
        }
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

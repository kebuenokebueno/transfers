//
//  TransactionListView.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import SwiftUI


struct TransactionListView: View {
    @State private var viewController: TransactionListViewController
    @Environment(AuthService.self) private var authService
    @Environment(AnalyticsService.self) private var analyticsService
    
    init() {
        // Note: Can't access @Environment in init, will inject in onAppear
        _viewController = State(initialValue: TransactionListViewController(
            analyticsService: AnalyticsService()
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // ✅ View can use AuthService for UI decisions (not business logic)
                UserHeaderView()
                
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
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // ✅ View can track UI events directly
                        analyticsService.trackButtonTap("logout")
                        authService.logout()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .onAppear {
                // ✅ View can track screen views
                analyticsService.trackScreenView("TransactionList")
                
                // Re-create ViewController with injected service
                viewController = TransactionListViewController(
                    analyticsService: analyticsService
                )
                
                // ✅ Business logic goes through VIP
                viewController.loadTransactions()
            }
        }
    }
}

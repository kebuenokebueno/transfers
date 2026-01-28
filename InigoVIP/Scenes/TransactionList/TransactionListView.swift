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
        // We'll inject analytics in onAppear since we can't access @Environment in init
        _viewController = State(initialValue: TransactionListViewController())
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // User info header using @Environment
                UserHeaderView()
                
                ZStack {
                    if viewController.isLoading {
                        ProgressView()
                            .accessibilityIdentifier("loadingIndicator")
                    } else {
                        List(viewController.displayedTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                                .accessibilityIdentifier("transactionRow_\(transaction.id)")
                                .onTapGesture {
                                    analyticsService.trackButtonTap("transaction_\(transaction.id)")
                                }
                        }
                        .accessibilityIdentifier("transactionsList")
                    }
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        analyticsService.trackButtonTap("logout")
                        authService.logout()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .onAppear {
                analyticsService.trackScreenView("TransactionList")
                // Inject analytics service into the interactor
                if let interactor = viewController.interactor as? TransactionListInteractor {
                    viewController = TransactionListViewController(analyticsService: analyticsService)
                }
                viewController.loadTransactions()
            }
        }
    }
}



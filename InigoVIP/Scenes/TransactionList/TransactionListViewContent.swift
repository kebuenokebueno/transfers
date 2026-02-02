//
//  TransactionListViewContent.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import Foundation
import SwiftUI

struct TransactionListViewContent: View {
    @Bindable var viewController: TransactionListViewController
    let authService: AuthService
    let analyticsService: AnalyticsService
    let router: Router
    
    var body: some View {
        let _ = print("🔷 ViewContent: body called - isLoading: \(viewController.isLoading), transactions count: \(viewController.displayedTransactions.count)")
        
        NavigationStack {
            VStack(spacing: 0) {
                // ✅ User header at the top
                UserHeaderView()
                    .environment(authService)
                
                Group {
                    if viewController.isLoading {
                        ProgressView("Loading transactions...")
                            // ✅ VoiceOver: Announce loading state
                            .accessibilityLabel("Loading your transactions")
                            .accessibilityAddTraits(.updatesFrequently)
                    } else if !viewController.displayedTransactions.isEmpty {
                        TransactionListContent(
                            transactions: viewController.displayedTransactions,
                            analyticsService: analyticsService
                        )
                    } else {
                        ContentUnavailableView(
                            "No Transactions",
                            systemImage: "list.bullet.rectangle",
                            description: Text("Pull to refresh")
                        )
                        // ✅ VoiceOver: Clear hint for action
                        .accessibilityHint("Swipe down to refresh and load transactions")
                    }
                }
            }
            .navigationTitle("Transactions")
            // ✅ VoiceOver: Custom label for navigation title
            .accessibilityElement(children: .contain)
            .refreshable {
                // ✅ VoiceOver: Announce refresh completion
                viewController.loadTransactions()
                UIAccessibility.post(notification: .announcement, argument: "Transactions refreshed")
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        analyticsService.trackButtonTap("settings")
                        router.navigate(to: .settings)
                    } label: {
                        Image(systemName: "gearshape")
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityHint("Open settings")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        analyticsService.trackButtonTap("logout")
                        authService.logout()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityLabel("Log out")
                    .accessibilityHint("Double tap to log out of your account")
                    .accessibilityIdentifier("logoutButton")
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        analyticsService.trackButtonTap("add_transaction")
                        router.present(sheet: .addTransaction)
                    } label: {
                        Label("Add Transaction", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Add new transaction")
                }
            }
        }
    }
}

//
//  TransactionListView.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import SwiftUI

struct TransactionListView: View {
    @Environment(AuthService.self) private var authService
    @Environment(AnalyticsService.self) private var analyticsService
    @State private var viewController: TransactionListViewController
    
    // ✅ VoiceOver: Dynamic Type support
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    // ✅ Assistive Access: Reduced motion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    init() {
        // Note: We can't access @Environment in init, so we'll use a placeholder
        // The actual setup happens in .task modifier
        _viewController = State(initialValue: TransactionListViewController(analyticsService: AnalyticsService()))
    }
    
    var body: some View {
        @Bindable var viewController = viewController
        
        NavigationStack {
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
            .navigationTitle("Transactions")
            // ✅ VoiceOver: Custom label for navigation title
            .accessibilityElement(children: .contain)
            .refreshable {
                // ✅ VoiceOver: Announce refresh completion
                viewController.loadTransactions()
                UIAccessibility.post(notification: .announcement, argument: "Transactions refreshed")
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        analyticsService.trackButtonTap("logout")
                        authService.logout()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                    // ✅ VoiceOver: Descriptive label instead of icon
                    .accessibilityLabel("Log out")
                    .accessibilityHint("Double tap to log out of your account")
                    // ✅ VoiceControl: Named action
                    .accessibilityIdentifier("logoutButton")
                }
            }
            .task {
                // Reinitialize with the actual analyticsService from Environment
                viewController = TransactionListViewController(analyticsService: analyticsService)
                viewController.loadTransactions()
            }
        }
        // ✅ Accessibility Nutrition Label: Scene information
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Transaction List Screen")
    }
}

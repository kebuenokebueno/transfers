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
    @State private var viewController: TransactionListViewController?
    
    // ✅ VoiceOver: Dynamic Type support
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        Group {
            if let viewController = viewController {
                TransactionListViewContent(
                    viewController: viewController,
                    authService: authService,
                    analyticsService: analyticsService
                )
            } else {
                ProgressView("Initializing...")
            }
        }
        .task {
            // Initialize with the actual analyticsService from Environment
            if viewController == nil {
                let vc = TransactionListViewController(analyticsService: analyticsService)
                viewController = vc
                vc.loadTransactions()
            }
        }
        // ✅ Accessibility Nutrition Label: Scene information
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Transaction List Screen")
    }
}

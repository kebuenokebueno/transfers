//
//  InigoVIPApp.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import SwiftUI


@main
struct InigoVIPApp: App {
    @State private var authService = AuthService()
    @State private var analyticsService = AnalyticsService()
    
    var body: some Scene {
        WindowGroup {
            TransactionListView()
                .environment(authService)
                .environment(analyticsService)
        }
    }
}

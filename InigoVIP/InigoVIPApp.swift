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
    @State private var router = Router()
    @State private var swiftDataService = SwiftDataService()
    
    var body: some Scene {
        WindowGroup {
            if authService.isLoggedIn {
                NavigationStack(path: $router.path) {
                    TransactionListView()
                        .environment(authService)
                        .environment(analyticsService)
                        .environment(router)
                        .environment(swiftDataService)
                        .navigationDestination(for: Route.self) { route in
                            RouterView.destination(for: route)
                                .environment(authService)
                                .environment(analyticsService)
                                .environment(router)
                                .environment(swiftDataService)
                        }
                }
                .sheet(item: $router.presentedSheet) { route in
                    RouterView.destination(for: route)
                        .environment(authService)
                        .environment(analyticsService)
                        .environment(router)
                        .environment(swiftDataService)
                }
                .fullScreenCover(item: $router.presentedFullScreen) { route in
                    RouterView.destination(for: route)
                        .environment(authService)
                        .environment(analyticsService)
                        .environment(router)
                }
            } else {
                LoginView()
                    .environment(authService)
                    .environment(analyticsService)
                    .environment(router)
                    .environment(swiftDataService)
            }
        }
    }
}

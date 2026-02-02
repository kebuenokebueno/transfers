//
//  SettingsView.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @Environment(Router.self) private var router
    @Environment(AuthService.self) private var authService
    @Environment(AnalyticsService.self) private var analyticsService
    
    var body: some View {
        List {
            Section("Account") {
                Button {
                    analyticsService.trackButtonTap("view_profile")
                    router.navigate(to: .profile)
                } label: {
                    Label("Profile", systemImage: "person.circle")
                }
                
                Button(role: .destructive) {
                    analyticsService.trackButtonTap("logout_from_settings")
                    authService.logout()
                    router.navigateToRoot()
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
            
            Section("Preferences") {
                Toggle(isOn: .constant(true)) {
                    Label("Notifications", systemImage: "bell")
                }
                
                Toggle(isOn: .constant(false)) {
                    Label("Face ID", systemImage: "faceid")
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .accessibilityLabel("Settings Screen")
    }
}

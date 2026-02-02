//
//  ProfileView.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @Environment(AuthService.self) private var authService
    @Environment(AnalyticsService.self) private var analyticsService
    @Environment(SwiftDataService.self) private var swiftDataService
    @State private var stats: TransactionStatistics?
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 24) {
                if let user = authService.currentUser {
                    // Profile Picture
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text(String(user.name.prefix(1)))
                                .font(.system(size: 56))
                                .foregroundColor(.white)
                        )
                        .accessibilityLabel("Profile picture, \(user.name)")
                    
                    // Name
                    Text(user.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Email
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Stats
                    HStack(spacing: 40) {
                        StatItem(label: "Transactions", value: "45")
                        StatItem(label: "This Month", value: "€2,345")
                        StatItem(label: "Balance", value: "€12,456")
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .task {
//            stats = try? await swiftDataService.fetchStatistics()
        }
        .navigationTitle("Profile")
        .onAppear {
            analyticsService.trackScreenView("profile")
        }
    }
}

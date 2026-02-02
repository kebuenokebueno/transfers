//
//  AuthService.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import Observation



@Observable
class AuthService {
    var isLoggedIn = true
    var currentUser: User?
    
    // Reference to SwiftData service
    weak var swiftDataService: SwiftDataService?

    
    init() {
        currentUser = User(name: "John Doe", email: "john@example.com")
    }
    
    func login(email: String, password: String) async {
        // Simulate login
        isLoggedIn = true
    }
    
    func logout() {
        Task { @MainActor in
            // Clear all user data FIRST
            try? await swiftDataService?.clearAllUserData()
            
            // Then clear auth
            isLoggedIn = false
            currentUser = nil
            
            print("✅ User logged out and all data cleared")
        }
    }
}

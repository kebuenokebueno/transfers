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
    
    init() {
        currentUser = User(name: "John Doe", email: "john@example.com")
    }
    
    func login(email: String, password: String) async {
        // Simulate login
        isLoggedIn = true
    }
    
    func logout() {
        isLoggedIn = false
        currentUser = nil
    }
}

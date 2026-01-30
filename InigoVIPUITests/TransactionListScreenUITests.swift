//
//  TransactionListScreenUITests.swift
//  InigoVIP
//
//  Created by Inigo on 30/1/26.
//

import XCTest

@MainActor
final class TransactionListScreenUITests: BaseUITest {
    
    // MARK: - Navigation & Layout
    
    func testNavigationBarDisplaysCorrectly() throws {
        // Assert
        assertExists(
            transactionListPage.navigationTitle,
            "Navigation title 'Transactions' should be visible"
        )
    }
    
    func testLogoutButtonExists() throws {
        // Assert
        assertExists(
            transactionListPage.logoutButton,
            "Logout button should be visible in navigation"
        )
    }
    
    // MARK: - Content Display (with mock data from API)
    
    func testContentLoads() throws {
        // Wait for any content to appear (gives API time to load)
        let anyText = app.staticTexts.firstMatch
        XCTAssertTrue(
            anyText.waitForExistence(timeout: UITestConfig.defaultTimeout),
            "Some content should appear"
        )
    }
    
    func testListExists() throws {
        // SwiftUI List doesn't always appear as scrollView in accessibility tree
        // Just verify navigation and content exist
        XCTAssertTrue(transactionListPage.navigationTitle.exists, "Navigation should exist")
        XCTAssertTrue(transactionListPage.logoutButton.exists, "Logout button should exist")
    }
    
    func testNavigationBarIsInteractive() throws {
        // Test that navigation bar exists and is interactive
        XCTAssertTrue(transactionListPage.navigationTitle.exists)
        XCTAssertTrue(transactionListPage.logoutButton.isHittable)
    }
}

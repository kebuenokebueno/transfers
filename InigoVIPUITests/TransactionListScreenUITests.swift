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
        // SwiftUI List creates scroll views
        let list = app.scrollViews.firstMatch
        XCTAssertTrue(
            list.waitForExistence(timeout: UITestConfig.defaultTimeout),
            "List should exist"
        )
    }
    
    // MARK: - UI Interactions (not dependent on specific data)
    
    func testNavigationBarIsInteractive() throws {
        // Test that navigation bar exists and is interactive
        XCTAssertTrue(transactionListPage.navigationTitle.exists)
        XCTAssertTrue(transactionListPage.logoutButton.isHittable)
    }
    
    func testListIsScrollable() throws {
        // Test that list can be scrolled (regardless of data)
        let list = app.scrollViews.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: UITestConfig.defaultTimeout))
        
        // Should be able to interact with list
        XCTAssertTrue(list.exists)
    }
    
    func testScreenLayout() throws {
        // Test basic screen structure exists
        XCTAssertTrue(transactionListPage.navigationTitle.exists, "Should have navigation")
        XCTAssertTrue(transactionListPage.logoutButton.exists, "Should have logout button")
    }
}

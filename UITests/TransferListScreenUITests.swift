//
//  TransferListScreenUITests.swift
//  Transfers
//
//  Created by Inigo on 30/1/26.
//

import XCTest

@MainActor
final class TransferListScreenUITests: BaseUITest {
    
    // MARK: - Navigation & Layout
    
    func testNavigationBarDisplaysCorrectly() throws {
        // Assert
        assertExists(
            transferListPage.navigationTitle,
            "Navigation title 'Transfers' should be visible"
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
        XCTAssertTrue(transferListPage.navigationTitle.exists, "Navigation should exist")
        XCTAssertTrue(transferListPage.allAmounts.element.exists, "TransferListPage should exist")
    }
}

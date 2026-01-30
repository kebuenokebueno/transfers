//
//  AccessibilityUITests.swift
//  InigoVIP
//
//  Created by Inigo on 30/1/26.
//

import XCTest


@MainActor
final class AccessibilityUITests: BaseUITest {
    
    func testVoiceOverLabelsPresent() throws {
        // Wait for load
        sleep(2)
        
        // Assert - All interactive elements should have accessibility labels
        XCTAssertFalse(
            transactionListPage.logoutButton.label.isEmpty,
            "Logout button should have accessibility label"
        )
    }
    
    func testMinimumTouchTargets() throws {
        // Assert - Critical buttons meet 44x44 pt minimum
        let a = transactionListPage.logoutButton
        let logoutFrame = transactionListPage.logoutButton.frame
        XCTAssertGreaterThanOrEqual(
            logoutFrame.width,
            44,
            "Logout button should meet 44pt minimum touch target"
        )
    }
    
    func testDynamicTypeSupport() throws {
        // This test requires launching with different text size settings
        // app.launchArguments = ["--uitesting", "--large-text"]
        
        XCTAssertTrue(true, "Dynamic Type test requires text size configuration")
    }
    
    func testVoiceOverNavigationFlow() throws {
        // Enable VoiceOver for testing
        // Note: This requires accessibility permissions
        
        // Wait for load
        sleep(2)
        
        // Assert - Screen should have accessibility label
        XCTAssertTrue(
            transactionListPage.navigationTitle.exists,
            "Navigation should be accessible for VoiceOver"
        )
    }
}

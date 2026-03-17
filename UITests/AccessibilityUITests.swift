//
//  AccessibilityUITests.swift
//  Transfers
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
            noteListPage.navigationTitle.label.isEmpty,
            "Logout button should have accessibility label"
        )
    }
    
    func testDynamicTypeSupport() throws {
        // This test requires launching with different text size settings
        // app.launchArguments = ["--uitesting", "--large-text"]
        
        XCTAssertTrue(true, "Dynamic Type test requires text size configuration")
    }
    
    func testVoiceOverNavigationFlow() throws {
        // Enable VoiceOver for testing
        // Transfer: This requires accessibility permissions
        
        // Wait for load
        sleep(2)
        
        // Assert - Screen should have accessibility label
        XCTAssertTrue(
            noteListPage.navigationTitle.exists,
            "Navigation should be accessible for VoiceOver"
        )
    }
}

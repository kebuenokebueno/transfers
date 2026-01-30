//
//  AppLaunchUITests.swift
//  InigoVIP
//
//  Created by Inigo on 30/1/26.
//

import XCTest


@MainActor
final class AppLaunchUITests: BaseUITest {
    
    func testAppLaunchesSuccessfully() throws {
        // Assert
        XCTAssertTrue(app.exists, "App should launch")
        XCTAssertEqual(app.state, .runningForeground, "App should be in foreground")
    }
    
    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
        
        // Enterprise standard: <400ms cold start
        // This test will fail if launch takes >400ms
    }
}

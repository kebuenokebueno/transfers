//
//  BaseUITest.swift
//  InigoVIP
//
//  Created by Inigo on 30/1/26.
//

import XCTest


class BaseUITest: XCTestCase {
    var app: XCUIApplication!
    var noteListPage: NoteListPage!
    var editPage: NoteEditPage!


    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        
        // Initialize page objects
        noteListPage = NoteListPage(app: app)
        editPage = NoteEditPage(app: app)
    }
    
    override func tearDownWithError() throws {
        app = nil
        noteListPage = nil
        editPage = nil
    }
    
    // MARK: - Helper Methods
    
    /// Takes a screenshot for debugging
    func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    /// Waits for an element with custom timeout
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = UITestConfig.defaultTimeout, file: StaticString = #file, line: UInt = #line) -> Bool {
        let exists = element.waitForExistence(timeout: timeout)
        if !exists {
            takeScreenshot(named: "Element_Not_Found_\(element.debugDescription)")
        }
        return exists
    }
    
    /// Verifies element exists with helpful error
    func assertExists(_ element: XCUIElement, _ message: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(
            waitForElement(element, timeout: UITestConfig.defaultTimeout, file: file, line: line),
            message,
            file: file,
            line: line
        )
    }
}

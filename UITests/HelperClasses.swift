//
//  HelperClasses.swift
//  Transfers
//
//  Created by Inigo on 30/1/26.
//

import Foundation
import XCTest


enum UITestConfig {
    static let defaultTimeout: TimeInterval = 15.0
    static let shortTimeout: TimeInterval = 5.0
    static let longTimeout: TimeInterval = 15.0
    static let animationDelay: TimeInterval = 0.5
}

// MARK: - Page Object Pattern

// Page Object for transfer List Screen
struct TransferListPage {
    let app: XCUIApplication
    
    // MARK: - Elements
    
    var navigationTitle: XCUIElement {
        app.staticTexts["Transfers"]
    }
    
    var refreshControl: XCUIElement {
        app.otherElements["refreshControl"]
    }
    
    // Transfer Elements
    func transferRow(withId id: String) -> XCUIElement {
        app.otherElements["transfer_\(id)"]
    }
    
    func transferDescription(_ text: String) -> XCUIElement {
        app.staticTexts[text]
    }
    
    func categoryBadge(_ category: String) -> XCUIElement {
        app.staticTexts[category]
    }
    
    var allAmounts: XCUIElementQuery {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS '€'"))
    }
    
    var allTransferDescriptions: XCUIElementQuery {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'accusamus' OR label CONTAINS 'reprehenderit' OR label CONTAINS 'officia'"))
    }
    
    // MARK: - Actions
    
    @discardableResult
    func waitForLoad(timeout: TimeInterval = UITestConfig.defaultTimeout) -> Bool {
        navigationTitle.waitForExistence(timeout: timeout)
    }
    
    func pullToRefresh() {
        let firstCell = app.cells.firstMatch
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 1.5))
        start.press(forDuration: 0, thenDragTo: finish)
    }
    
    // MARK: - Assertions
    
    func verifyNavigationExists() -> Bool {
        navigationTitle.exists
    }
}

/// Page Object for Transfer Edit Screen
struct TransferEditPage {
    let app: XCUIApplication
    
    // MARK: - Elements
    
    var navigationTitle: XCUIElement {
        app.staticTexts["Edit Transfer Screen"]
    }
    
    var descriptionField: XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Description'")).firstMatch
    }
    
    var amountField: XCUIElement {
        app.textFields["amountField"]
    }
    
    var categoryPicker: XCUIElement {
        app.pickers["categoryPicker"]
    }
    
    var saveButton: XCUIElement {
        app.buttons["saveButton"]
    }
    
    var cancelButton: XCUIElement {
        app.buttons["cancelButton"]
    }
    
    // MARK: - Actions
    
    @discardableResult
    func waitForLoad(timeout: TimeInterval = UITestConfig.defaultTimeout) -> Bool {
        amountField.waitForExistence(timeout: timeout)
    }
    
    func enterAmount(_ amount: String) {
        amountField.tap()
        amountField.typeText(amount)
    }
    
    func tapSave() {
        saveButton.tap()
    }
    
    func tapCancel() {
        cancelButton.tap()
    }
}

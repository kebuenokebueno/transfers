//
//  HelperClasses.swift
//  InigoVIP
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

/// Page Object for Transaction List Screen
struct TransactionListPage {
    let app: XCUIApplication
    
    // MARK: - Elements
    
    var navigationTitle: XCUIElement {
        app.staticTexts["Transactions"]
    }
    
    var logoutButton: XCUIElement {
        app.buttons["logoutButton"]
    }
    
    var refreshControl: XCUIElement {
        app.otherElements["refreshControl"]
    }
    
    // Transaction Elements
    func transactionRow(withId id: String) -> XCUIElement {
        app.otherElements["transaction_\(id)"]
    }
    
    func transactionDescription(_ text: String) -> XCUIElement {
        app.staticTexts[text]
    }
    
    func categoryBadge(_ category: String) -> XCUIElement {
        app.staticTexts[category]
    }
    
    var allAmounts: XCUIElementQuery {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS '€'"))
    }
    
    var allTransactionDescriptions: XCUIElementQuery {
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
    
    func tapTransaction(withId id: String) {
        transactionRow(withId: id).tap()
    }
    
    func tapLogout() {
        logoutButton.tap()
    }
    
    // MARK: - Assertions
    
    func verifyNavigationExists() -> Bool {
        navigationTitle.exists
    }
    
    func verifyTransactionExists(_ description: String) -> Bool {
        transactionDescription(description).exists
    }
    
    func countVisibleTransactions() -> Int {
        allTransactionDescriptions.count
    }
}

/// Page Object for Login Screen
struct LoginPage {
    let app: XCUIApplication
    
    // MARK: - Elements
    
    var emailField: XCUIElement {
        app.textFields["emailField"]
    }
    
    var passwordField: XCUIElement {
        app.secureTextFields["passwordField"]
    }
    
    var loginButton: XCUIElement {
        app.buttons["loginButton"]
    }
    
    var welcomeText: XCUIElement {
        app.staticTexts["Welcome Back"]
    }
    
    var loadingIndicator: XCUIElement {
        app.activityIndicators.firstMatch
    }
    
    // MARK: - Actions
    
    @discardableResult
    func waitForLoad(timeout: TimeInterval = UITestConfig.defaultTimeout) -> Bool {
        welcomeText.waitForExistence(timeout: timeout) || emailField.waitForExistence(timeout: timeout)
    }
    
    func enterEmail(_ email: String) {
        emailField.tap()
        emailField.typeText(email)
    }
    
    func enterPassword(_ password: String) {
        passwordField.tap()
        passwordField.typeText(password)
    }
    
    func tapLogin() {
        loginButton.tap()
    }
    
    func performLogin(email: String, password: String) {
        enterEmail(email)
        enterPassword(password)
        tapLogin()
    }
    
    // MARK: - Assertions
    
    func verifyLoginScreenDisplayed() -> Bool {
        welcomeText.exists || emailField.exists
    }
    
    func verifyLoadingIndicatorShown() -> Bool {
        loadingIndicator.exists
    }
}

/// Page Object for Transaction Edit Screen
struct TransactionEditPage {
    let app: XCUIApplication
    
    // MARK: - Elements
    
    var navigationTitle: XCUIElement {
        app.staticTexts["Edit Transaction Screen"]
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
    
    func selectCategory(_ category: String) {
        categoryPicker.tap()
        // Swipe to find category
        categoryPicker.adjust(toPickerWheelValue: category)
    }
    
    func tapSave() {
        saveButton.tap()
    }
    
    func tapCancel() {
        cancelButton.tap()
    }
}

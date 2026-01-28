
import XCTest

// MARK: - XCTest UI Tests for SwiftUI
final class TransactionListUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testAppLaunches() throws {
        XCTAssertTrue(app.exists)
    }
    
    func testNavigationBarExists() throws {
        // In SwiftUI, navigation title appears as static text
        let navTitle = app.staticTexts["Transactions"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Navigation title should exist")
    }
    
//    func testLoadingIndicatorAppearsAndDisappears() throws {
//        // ProgressView appears as a progress indicator
//        let loadingIndicator = app.progressIndicators.firstMatch
//        
//        // Loading might be too fast to catch, so we just check if list appears
//        let list = app.scrollViews.firstMatch
//        XCTAssertTrue(list.waitForExistence(timeout: 5), "Content should appear")
//    }
    
    func testTransactionContentAppears() throws {
        // Wait for any static text to appear (transactions loaded)
        let firstText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Grocery' OR label CONTAINS 'Electric' OR label CONTAINS 'Salary'")).firstMatch
        XCTAssertTrue(firstText.waitForExistence(timeout: 5), "Transaction content should appear")
    }
    
    func testGroceryTransactionExists() throws {
        // Check for specific transaction
        let groceryText = app.staticTexts["Grocery Store"]
        XCTAssertTrue(groceryText.waitForExistence(timeout: 5), "Grocery Store transaction should exist")
    }
    
    func testElectricBillTransactionExists() throws {
        let electricText = app.staticTexts["Electric Bill"]
        XCTAssertTrue(electricText.waitForExistence(timeout: 5), "Electric Bill transaction should exist")
    }
    
    func testSalaryTransactionExists() throws {
        let salaryText = app.staticTexts["Salary"]
        XCTAssertTrue(salaryText.waitForExistence(timeout: 5), "Salary transaction should exist")
    }
    
    func testCategoryLabelsExist() throws {
        // Check for category labels
        let foodCategory = app.staticTexts["Food"]
        let utilitiesCategory = app.staticTexts["Utilities"]
        let incomeCategory = app.staticTexts["Income"]
        
        XCTAssertTrue(foodCategory.waitForExistence(timeout: 5), "Food category should exist")
        XCTAssertTrue(utilitiesCategory.exists, "Utilities category should exist")
        XCTAssertTrue(incomeCategory.exists, "Income category should exist")
    }
    
    func testAmountsDisplayed() throws {
        // Check that amounts with currency symbols exist
        let amounts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '€'"))
        XCTAssertGreaterThan(amounts.count, 0, "Should display amounts with currency")
    }
    
    func testNegativeAmountWithMinus() throws {
        // Look for negative amounts (should have - sign)
        let negativeAmount = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH '-'")).firstMatch
        XCTAssertTrue(negativeAmount.waitForExistence(timeout: 5), "Negative amounts should have minus sign")
    }
    
    func testPositiveAmountWithPlus() throws {
        // Look for positive amounts (should have + sign)
        let positiveAmount = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH '+'")).firstMatch
        XCTAssertTrue(positiveAmount.waitForExistence(timeout: 5), "Positive amounts should have plus sign")
    }
    
    func testDatesDisplayed() throws {
        // Dates should be displayed (looking for month patterns)
        let dateText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Jan' OR label CONTAINS '2026'")).firstMatch
        XCTAssertTrue(dateText.waitForExistence(timeout: 5), "Dates should be displayed")
    }
    
//    func testScrollViewExists() throws {
//        // SwiftUI List creates a scroll view
//        let scrollView = app.scrollViews.firstMatch
//        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Scroll view should exist")
//    }
//    
//    func testCanScrollContent() throws {
//        let scrollView = app.scrollViews.firstMatch
//        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
//        
//        // Try to scroll
//        scrollView.swipeUp()
//        scrollView.swipeDown()
//        
//        // Should still exist after scrolling
//        XCTAssertTrue(scrollView.exists, "Should be able to scroll")
//    }
    
    func testMultipleTransactionsVisible() throws {
        // Count static texts that are transaction descriptions
        let groceryExists = app.staticTexts["Grocery Store"].exists
        let electricExists = app.staticTexts["Electric Bill"].exists
        let salaryExists = app.staticTexts["Salary"].exists
        
        // Wait for content to load
        _ = app.staticTexts["Grocery Store"].waitForExistence(timeout: 5)
        
        let visibleCount = [groceryExists, electricExists, salaryExists].filter { $0 }.count
        XCTAssertGreaterThanOrEqual(visibleCount, 2, "At least 2 transactions should be visible")
    }
    
    func testTransactionDescriptionsAreNotEmpty() throws {
        let grocery = app.staticTexts["Grocery Store"]
        XCTAssertTrue(grocery.waitForExistence(timeout: 5))
        XCTAssertFalse(grocery.label.isEmpty, "Description should not be empty")
    }
    
    func testAllThreeMockTransactionsPresent() throws {
        // Wait for first transaction
        XCTAssertTrue(app.staticTexts["Grocery Store"].waitForExistence(timeout: 5))
        
        // Check all three exist
        XCTAssertTrue(app.staticTexts["Grocery Store"].exists, "Grocery transaction missing")
        XCTAssertTrue(app.staticTexts["Electric Bill"].exists, "Electric Bill transaction missing")
        XCTAssertTrue(app.staticTexts["Salary"].exists, "Salary transaction missing")
    }
}

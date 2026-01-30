import Testing
import XCTest
import SnapshotTesting
import SwiftUI
@testable import InigoVIP

struct SnapshotTestData {
    static func sampleTransaction(
        id: String = "1",
        amount: Double = -45.50,
        description: String = "Grocery Store",
        category: String = "Food"
    ) -> TransactionList.FetchTransactions.ViewModel.DisplayedTransaction {
        TransactionList.FetchTransactions.ViewModel.DisplayedTransaction(
            id: id,
            amount: "€\(abs(amount))",
            description: description,
            date: "Jan 25, 2026",
            category: category,
            isPositive: amount >= 0,
            thumbnailUrl: "https://via.placeholder.com/150"
        )
    }
    
    static var sampleTransactions: [TransactionList.FetchTransactions.ViewModel.DisplayedTransaction] {
        [
            sampleTransaction(id: "1", amount: -45.50, description: "Grocery Store", category: "Food"),
            sampleTransaction(id: "2", amount: -120.00, description: "Electric Bill", category: "Utilities"),
            sampleTransaction(id: "3", amount: 2500.00, description: "Salary", category: "Income"),
            sampleTransaction(id: "4", amount: -30.00, description: "Gas Station", category: "Transport"),
            sampleTransaction(id: "5", amount: 150.00, description: "Freelance Work", category: "Income")
        ]
    }
}

// MARK: - Transaction Row Snapshot Tests
var recording = false

final class TransactionRowSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Snapshots will record based on recordMode above
    }
    
    // MARK: - Basic States
    
    func testTransactionRow_Expense() {
        
        let transaction = SnapshotTestData.sampleTransaction(amount: -45.50)
        let view = TransactionRow(transaction: transaction)
            .frame(width: 375, height: 80)
            .padding()
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransactionRow_Income() {
        let transaction = SnapshotTestData.sampleTransaction(amount: 2500.00, description: "Salary", category: "Income")
        let view = TransactionRow(transaction: transaction)
            .frame(width: 375, height: 80)
            .padding()
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransactionRow_LongDescription() {
        let transaction = SnapshotTestData.sampleTransaction(
            description: "Very Long Transaction Description That Should Wrap To Multiple Lines"
        )
        let view = TransactionRow(transaction: transaction)
            .frame(width: 375, height: 100)
            .padding()
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    // MARK: - Dark Mode
    
    func testTransactionRow_DarkMode() {
        let transaction = SnapshotTestData.sampleTransaction()
        let view = TransactionRow(transaction: transaction)
            .frame(width: 375, height: 80)
            .padding()
            .preferredColorScheme(.dark)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransactionRow_Income_DarkMode() {
        let transaction = SnapshotTestData.sampleTransaction(amount: 2500.00)
        let view = TransactionRow(transaction: transaction)
            .frame(width: 375, height: 80)
            .padding()
            .preferredColorScheme(.dark)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    // MARK: - Dynamic Type
    
    func testTransactionRow_LargeText() {
        let transaction = SnapshotTestData.sampleTransaction()
        let view = TransactionRow(transaction: transaction)
            .frame(width: 375, height: 120)
            .padding()
            .environment(\.dynamicTypeSize, .accessibility3)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransactionRow_ExtraLargeText() {
        let transaction = SnapshotTestData.sampleTransaction()
        let view = TransactionRow(transaction: transaction)
            .frame(width: 375, height: 150)
            .padding()
            .environment(\.dynamicTypeSize, .accessibility5)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    // MARK: - All Categories
    
    func testTransactionRow_AllCategories() {
        let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]
        
        for category in categories {
            let transaction = SnapshotTestData.sampleTransaction(
                id: category,
                description: "\(category) Transaction",
                category: category
            )
            let view = TransactionRow(transaction: transaction)
                .frame(width: 375, height: 80)
                .padding()
            
            assertSnapshot(of: view, as: .image, named: "category_\(category)", record: recording)
        }
    }
}

// MARK: - Transaction List Snapshot Tests

final class TransactionListSnapshotTests: XCTestCase {
    var analyticsService: AnalyticsService!
    
    override func setUp() {
        super.setUp()
        analyticsService = AnalyticsService()
    }
    
    func testTransactionList_Empty() {
        let viewModel = TransactionList.FetchTransactions.ViewModel(transactions: [])
        let view = TransactionListContent(transactions: viewModel.transactions, analyticsService: analyticsService)
            .frame(width: 375, height: 667)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransactionList_WithData() {
        let viewModel = TransactionList.FetchTransactions.ViewModel(
            transactions: SnapshotTestData.sampleTransactions
        )
        let view = TransactionListContent(transactions: viewModel.transactions, analyticsService: analyticsService)
            .frame(width: 375, height: 667)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransactionList_DarkMode() {
        let viewModel = TransactionList.FetchTransactions.ViewModel(
            transactions: SnapshotTestData.sampleTransactions
        )
        let view = TransactionListContent(transactions: viewModel.transactions, analyticsService: analyticsService)
            .frame(width: 375, height: 667)
            .preferredColorScheme(.dark)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransactionList_LargeText() {
        let viewModel = TransactionList.FetchTransactions.ViewModel(
            transactions: SnapshotTestData.sampleTransactions
        )
        let view = TransactionListContent(transactions: viewModel.transactions, analyticsService: analyticsService)
            .frame(width: 375, height: 667)
            .environment(\.dynamicTypeSize, .accessibility3)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
}

// MARK: - Device-Specific Snapshots

final class DeviceSpecificSnapshotTests: XCTestCase {
    var analyticsService: AnalyticsService!
    
    override func setUp() {
        super.setUp()
        analyticsService = AnalyticsService()
    }
    
    func testTransactionList_iPhoneSE() {
        let viewModel = TransactionList.FetchTransactions.ViewModel(
            transactions: SnapshotTestData.sampleTransactions
        )
        let view = TransactionListContent(transactions: viewModel.transactions, analyticsService: analyticsService)
            .frame(width: 320, height: 568)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransactionList_iPhone15() {
        let viewModel = TransactionList.FetchTransactions.ViewModel(
            transactions: SnapshotTestData.sampleTransactions
        )
        let view = TransactionListContent(transactions: viewModel.transactions, analyticsService: analyticsService)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransactionList_iPhone15ProMax() {
        let viewModel = TransactionList.FetchTransactions.ViewModel(
            transactions: SnapshotTestData.sampleTransactions
        )
        let view = TransactionListContent(transactions: viewModel.transactions, analyticsService: analyticsService)
            .frame(width: 430, height: 932)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransactionList_iPadPro() {
        let viewModel = TransactionList.FetchTransactions.ViewModel(
            transactions: SnapshotTestData.sampleTransactions
        )
        let view = TransactionListContent(transactions: viewModel.transactions, analyticsService: analyticsService)
            .frame(width: 1024, height: 1366)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
}

// MARK: - User Header Snapshots

final class UserHeaderSnapshotTests: XCTestCase {
    
    func testUserHeader_Default() {
        let authService = AuthService()
        authService.isLoggedIn = true
        authService.currentUser = User(name: "John Doe", email: "john@example.com")
        
        let view = UserHeaderView()
            .environment(authService)
            .frame(width: 375, height: 100)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testUserHeader_LongName() {
        let authService = AuthService()
        authService.isLoggedIn = true
        authService.currentUser = User(name: "Christopher Alexander Wellington", email: "christopher@example.com")
        
        let view = UserHeaderView()
            .environment(authService)
            .frame(width: 375, height: 100)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testUserHeader_DarkMode() {
        let authService = AuthService()
        authService.isLoggedIn = true
        authService.currentUser = User(name: "John Doe", email: "john@example.com")
        
        let view = UserHeaderView()
            .environment(authService)
            .frame(width: 375, height: 100)
            .preferredColorScheme(.dark)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testUserHeader_LargeText() {
        let authService = AuthService()
        authService.isLoggedIn = true
        authService.currentUser = User(name: "John Doe", email: "john@example.com")
        
        let view = UserHeaderView()
            .environment(authService)
            .frame(width: 375, height: 150)
            .environment(\.dynamicTypeSize, .accessibility3)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
}

// MARK: - Category Icon Snapshots

final class CategoryIconSnapshotTests: XCTestCase {
    
    func testCategoryIcons_AllCategories() {
        let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]
        
        for category in categories {
            let view = CategoryIcon(category: category)
                .frame(width: 100, height: 100)
                .padding()
            
            assertSnapshot(of: view, as: .image, named: "icon_\(category)", record: recording)
        }
    }
    
    func testCategoryIcons_DarkMode() {
        let categories = ["Food", "Utilities", "Income"]
        
        for category in categories {
            let view = CategoryIcon(category: category)
                .frame(width: 100, height: 100)
                .padding()
                .preferredColorScheme(.dark)
            
            assertSnapshot(of: view, as: .image, named: "icon_\(category)_dark", record: recording)
        }
    }
    
    func testCategoryIcon_AccessibilitySize() {
        let view = CategoryIcon(category: "Food")
            .frame(width: 100, height: 100)
            .padding()
            .environment(\.dynamicTypeSize, .accessibility5)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
}

// MARK: - Regression Tests

final class RegressionSnapshotTests: XCTestCase {
    var analyticsService: AnalyticsService!
    
    override func setUp() {
        super.setUp()
        analyticsService = AnalyticsService()
    }
    
    // This test captures the entire transaction list screen
    // If anything changes visually, this will catch it
    func testFullScreen_TransactionList() {
        let viewModel = TransactionList.FetchTransactions.ViewModel(
            transactions: SnapshotTestData.sampleTransactions
        )
        let view = TransactionListContent(transactions: viewModel.transactions, analyticsService: analyticsService)
            .frame(width: 375, height: 812)  // iPhone 15 size
        
        assertSnapshot(of: view, as: .image, named: "full_screen", record: recording)
    }
    
    // Test with many transactions (scrolling)
    func testFullScreen_ManyTransactions() {
        var manyTransactions: [TransactionList.FetchTransactions.ViewModel.DisplayedTransaction] = []
        for i in 1...20 {
            let amount = (i % 3 == 0) ? Double(i * 100) : -Double(i * 10)
            manyTransactions.append(
                SnapshotTestData.sampleTransaction(
                    id: "\(i)",
                    amount: amount,
                    description: "Transaction \(i)"
                )
            )
        }
        
        let viewModel = TransactionList.FetchTransactions.ViewModel(transactions: manyTransactions)
        let view = TransactionListContent(transactions: viewModel.transactions, analyticsService: analyticsService)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image, named: "many_transactions", record: recording)
    }
}

// MARK: - Precision Snapshot Tests (Different Precisions)

final class PrecisionSnapshotTests: XCTestCase {
    
    // Test with pixel-perfect precision (default)
    func testPrecision_PixelPerfect() {
        let transaction = SnapshotTestData.sampleTransaction()
        let view = TransactionRow(transaction: transaction)
            .frame(width: 375, height: 80)
        
        assertSnapshot(of: view, as: .image(precision: 1.0), record: recording)
    }
    
    // Test with 99% precision (allows tiny variations)
    func testPrecision_99Percent() {
        let transaction = SnapshotTestData.sampleTransaction()
        let view = TransactionRow(transaction: transaction)
            .frame(width: 375, height: 80)
        
        assertSnapshot(of: view, as: .image(precision: 0.99), record: recording)
    }
}

import Testing
import SwiftData
import XCTest
import SnapshotTesting
import SwiftUI
@testable import Transfers

struct SnapshotTestData {
    static func sampleTransfer(
        id: String = "1",
        amount: Double = -45.50,
        description: String = "Grocery Store",
        category: String = "Food"
    ) -> TransferViewModel {
        let formatted = amount >= 0
            ? "+€\(String(format: "%.2f", amount))"
            : "-€\(String(format: "%.2f", abs(amount)))"
        return TransferViewModel(
            id: id,
            amount: formatted,
            description: description,
            date: "Jan 25, 2026",
            category: category,
            isPositive: amount >= 0,
            syncStatus: "Pending"
        )
    }

    static var sampleTransfers: [TransferViewModel] {
        [
            sampleTransfer(id: "1", amount: -45.50,  description: "Grocery Store",  category: "Food"),
            sampleTransfer(id: "2", amount: -120.00, description: "Electric Bill",  category: "Utilities"),
            sampleTransfer(id: "3", amount: 2500.00, description: "Salary",         category: "Income"),
            sampleTransfer(id: "4", amount: -30.00,  description: "Gas Station",    category: "Transport"),
            sampleTransfer(id: "5", amount: 150.00,  description: "Freelance Work", category: "Income")
        ]
    }
}

// MARK: - Transfer Row Snapshot Tests
var recording = false

final class TransferRowSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Snapshots will record based on recordMode above
    }
    
    // MARK: - Basic States
    
    func testTransferRow_Expense() {
        
        let transfer = SnapshotTestData.sampleTransfer(amount: -45.50)
        let view = TransferRow(transfer: transfer)
            .frame(width: 375, height: 80)
            .padding()
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransferRow_Income() {
        let transfer = SnapshotTestData.sampleTransfer(amount: 2500.00, description: "Salary", category: "Income")
        let view = TransferRow(transfer: transfer)
            .frame(width: 375, height: 80)
            .padding()
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransferRow_LongDescription() {
        let transfer = SnapshotTestData.sampleTransfer(
            description: "Very Long Transfer Description That Should Wrap To Multiple Lines"
        )
        let view = TransferRow(transfer: transfer)
            .frame(width: 375, height: 100)
            .padding()
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    // MARK: - Dark Mode
    
    func testTransferRow_DarkMode() {
        let transfer = SnapshotTestData.sampleTransfer()
        let view = TransferRow(transfer: transfer)
            .frame(width: 375, height: 80)
            .padding()
            .preferredColorScheme(.dark)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransferRow_Income_DarkMode() {
        let transfer = SnapshotTestData.sampleTransfer(amount: 2500.00)
        let view = TransferRow(transfer: transfer)
            .frame(width: 375, height: 80)
            .padding()
            .preferredColorScheme(.dark)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    // MARK: - Dynamic Type
    
    func testTransferRow_LargeText() {
        let transfer = SnapshotTestData.sampleTransfer()
        let view = TransferRow(transfer: transfer)
            .frame(width: 375, height: 120)
            .padding()
            .environment(\.dynamicTypeSize, .accessibility3)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransferRow_ExtraLargeText() {
        let transfer = SnapshotTestData.sampleTransfer()
        let view = TransferRow(transfer: transfer)
            .frame(width: 375, height: 150)
            .padding()
            .environment(\.dynamicTypeSize, .accessibility5)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    // MARK: - All Categories
    
    func testTransferRow_AllCategories() {
        let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]
        
        for category in categories {
            let transfer = SnapshotTestData.sampleTransfer(
                id: category,
                description: "\(category) Transfer",
                category: category
            )
            let view = TransferRow(transfer: transfer)
                .frame(width: 375, height: 80)
                .padding()
            
            assertSnapshot(of: view, as: .image, named: "category_\(category)", record: recording)
        }
    }
}

final class TransferListSnapshotTests: XCTestCase {
    
    @MainActor
    func testTransferList_Empty() {
        let view = TransferListContent(transfers: [])
            .frame(width: 375, height: 667)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    func testTransferList_WithData() {
        let view = TransferListContent(transfers: SnapshotTestData.sampleTransfers)
            .frame(width: 375, height: 667)
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransferList_DarkMode() {
        let view = TransferListContent(transfers: SnapshotTestData.sampleTransfers)
            .frame(width: 375, height: 667)
            .preferredColorScheme(.dark)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransferList_LargeText() {
        let view = TransferListContent(transfers: SnapshotTestData.sampleTransfers)
            .frame(width: 375, height: 667)
            .environment(\.dynamicTypeSize, .accessibility3)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
}

// MARK: - Device-Specific Snapshots

final class DeviceSpecificSnapshotTests: XCTestCase {

    func testTransferList_iPhoneSE() {
        let view = TransferListContent(transfers: SnapshotTestData.sampleTransfers)
            .frame(width: 320, height: 568)
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransferList_iPhone15() {
        let view = TransferListContent(transfers: SnapshotTestData.sampleTransfers)
            .frame(width: 375, height: 812)
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransferList_iPhone15ProMax() {
        let view = TransferListContent(transfers: SnapshotTestData.sampleTransfers)
            .frame(width: 430, height: 932)
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testTransferList_iPadPro() {
        let view = TransferListContent(transfers: SnapshotTestData.sampleTransfers)
            .frame(width: 1024, height: 1366)
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

    // This test captures the entire transfer list screen
    // If anything changes visually, this will catch it
    func testFullScreen_TransferList() {
        let view = TransferListContent(transfers: SnapshotTestData.sampleTransfers)
            .frame(width: 375, height: 812)  // iPhone 15 size
        assertSnapshot(of: view, as: .image, named: "full_screen", record: recording)
    }
    
    // Test with many transfers (scrolling)
    func testFullScreen_ManyNotes() {
        let manyNotes: [TransferViewModel] = (1...20).map { i in
            let amount = (i % 3 == 0) ? Double(i * 100) : -Double(i * 10)
            return SnapshotTestData.sampleTransfer(id: "\(i)", amount: amount, description: "Transfer \(i)")
        }
        
        let view = TransferListContent(transfers: manyNotes)
            .frame(width: 375, height: 812)
        assertSnapshot(of: view, as: .image, named: "many_notes", record: recording)
    }
}

// MARK: - Precision Snapshot Tests (Different Precisions)

final class PrecisionSnapshotTests: XCTestCase {
    
    // Test with pixel-perfect precision (default)
    func testPrecision_PixelPerfect() {
        let transfer = SnapshotTestData.sampleTransfer()
        let view = TransferRow(transfer: transfer)
            .frame(width: 375, height: 80)
        
        assertSnapshot(of: view, as: .image(precision: 1.0), record: recording)
    }
    
    // Test with 99% precision (allows tiny variations)
    func testPrecision_99Percent() {
        let transfer = SnapshotTestData.sampleTransfer()
        let view = TransferRow(transfer: transfer)
            .frame(width: 375, height: 80)
        
        assertSnapshot(of: view, as: .image(precision: 0.99), record: recording)
    }
}

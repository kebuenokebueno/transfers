import Testing
import SwiftData
import XCTest
import SnapshotTesting
import SwiftUI
@testable import Transfers

struct SnapshotTestData {
    static func sampleNote(
        id: String = "1",
        amount: Double = -45.50,
        description: String = "Grocery Store",
        category: String = "Food"
    ) -> NoteViewModel {
        let formatted = amount >= 0
            ? "+€\(String(format: "%.2f", amount))"
            : "-€\(String(format: "%.2f", abs(amount)))"
        return NoteViewModel(
            id: id,
            amount: formatted,
            description: description,
            date: "Jan 25, 2026",
            category: category,
            isPositive: amount >= 0,
            syncStatus: "Pending"
        )
    }

    static var sampleNotes: [NoteViewModel] {
        [
            sampleNote(id: "1", amount: -45.50,  description: "Grocery Store",  category: "Food"),
            sampleNote(id: "2", amount: -120.00, description: "Electric Bill",  category: "Utilities"),
            sampleNote(id: "3", amount: 2500.00, description: "Salary",         category: "Income"),
            sampleNote(id: "4", amount: -30.00,  description: "Gas Station",    category: "Transport"),
            sampleNote(id: "5", amount: 150.00,  description: "Freelance Work", category: "Income")
        ]
    }
}

// MARK: - Note Row Snapshot Tests
var recording = false

final class NoteRowSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Snapshots will record based on recordMode above
    }
    
    // MARK: - Basic States
    
    func testNoteRow_Expense() {
        
        let note = SnapshotTestData.sampleNote(amount: -45.50)
        let view = NoteRow(note: note)
            .frame(width: 375, height: 80)
            .padding()
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testNoteRow_Income() {
        let note = SnapshotTestData.sampleNote(amount: 2500.00, description: "Salary", category: "Income")
        let view = NoteRow(note: note)
            .frame(width: 375, height: 80)
            .padding()
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testNoteRow_LongDescription() {
        let note = SnapshotTestData.sampleNote(
            description: "Very Long Note Description That Should Wrap To Multiple Lines"
        )
        let view = NoteRow(note: note)
            .frame(width: 375, height: 100)
            .padding()
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    // MARK: - Dark Mode
    
    func testNoteRow_DarkMode() {
        let note = SnapshotTestData.sampleNote()
        let view = NoteRow(note: note)
            .frame(width: 375, height: 80)
            .padding()
            .preferredColorScheme(.dark)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testNoteRow_Income_DarkMode() {
        let note = SnapshotTestData.sampleNote(amount: 2500.00)
        let view = NoteRow(note: note)
            .frame(width: 375, height: 80)
            .padding()
            .preferredColorScheme(.dark)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    // MARK: - Dynamic Type
    
    func testNoteRow_LargeText() {
        let note = SnapshotTestData.sampleNote()
        let view = NoteRow(note: note)
            .frame(width: 375, height: 120)
            .padding()
            .environment(\.dynamicTypeSize, .accessibility3)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testNoteRow_ExtraLargeText() {
        let note = SnapshotTestData.sampleNote()
        let view = NoteRow(note: note)
            .frame(width: 375, height: 150)
            .padding()
            .environment(\.dynamicTypeSize, .accessibility5)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    // MARK: - All Categories
    
    func testNoteRow_AllCategories() {
        let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]
        
        for category in categories {
            let note = SnapshotTestData.sampleNote(
                id: category,
                description: "\(category) Note",
                category: category
            )
            let view = NoteRow(note: note)
                .frame(width: 375, height: 80)
                .padding()
            
            assertSnapshot(of: view, as: .image, named: "category_\(category)", record: recording)
        }
    }
}

final class NoteListSnapshotTests: XCTestCase {
    
    @MainActor
    func testNoteList_Empty() {
        let view = NoteListContent(notes: [])
            .frame(width: 375, height: 667)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    func testNoteList_WithData() {
        let view = NoteListContent(notes: SnapshotTestData.sampleNotes)
            .frame(width: 375, height: 667)
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testNoteList_DarkMode() {
        let view = NoteListContent(notes: SnapshotTestData.sampleNotes)
            .frame(width: 375, height: 667)
            .preferredColorScheme(.dark)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testNoteList_LargeText() {
        let view = NoteListContent(notes: SnapshotTestData.sampleNotes)
            .frame(width: 375, height: 667)
            .environment(\.dynamicTypeSize, .accessibility3)
        
        assertSnapshot(of: view, as: .image, record: recording)
    }
}

// MARK: - Device-Specific Snapshots

final class DeviceSpecificSnapshotTests: XCTestCase {

    func testNoteList_iPhoneSE() {
        let view = NoteListContent(notes: SnapshotTestData.sampleNotes)
            .frame(width: 320, height: 568)
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testNoteList_iPhone15() {
        let view = NoteListContent(notes: SnapshotTestData.sampleNotes)
            .frame(width: 375, height: 812)
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testNoteList_iPhone15ProMax() {
        let view = NoteListContent(notes: SnapshotTestData.sampleNotes)
            .frame(width: 430, height: 932)
        assertSnapshot(of: view, as: .image, record: recording)
    }
    
    func testNoteList_iPadPro() {
        let view = NoteListContent(notes: SnapshotTestData.sampleNotes)
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

    // This test captures the entire note list screen
    // If anything changes visually, this will catch it
    func testFullScreen_NoteList() {
        let view = NoteListContent(notes: SnapshotTestData.sampleNotes)
            .frame(width: 375, height: 812)  // iPhone 15 size
        assertSnapshot(of: view, as: .image, named: "full_screen", record: recording)
    }
    
    // Test with many notes (scrolling)
    func testFullScreen_ManyNotes() {
        let manyNotes: [NoteViewModel] = (1...20).map { i in
            let amount = (i % 3 == 0) ? Double(i * 100) : -Double(i * 10)
            return SnapshotTestData.sampleNote(id: "\(i)", amount: amount, description: "Note \(i)")
        }
        
        let view = NoteListContent(notes: manyNotes)
            .frame(width: 375, height: 812)
        assertSnapshot(of: view, as: .image, named: "many_notes", record: recording)
    }
}

// MARK: - Precision Snapshot Tests (Different Precisions)

final class PrecisionSnapshotTests: XCTestCase {
    
    // Test with pixel-perfect precision (default)
    func testPrecision_PixelPerfect() {
        let note = SnapshotTestData.sampleNote()
        let view = NoteRow(note: note)
            .frame(width: 375, height: 80)
        
        assertSnapshot(of: view, as: .image(precision: 1.0), record: recording)
    }
    
    // Test with 99% precision (allows tiny variations)
    func testPrecision_99Percent() {
        let note = SnapshotTestData.sampleNote()
        let view = NoteRow(note: note)
            .frame(width: 375, height: 80)
        
        assertSnapshot(of: view, as: .image(precision: 0.99), record: recording)
    }
}

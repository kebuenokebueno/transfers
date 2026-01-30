// MARK: - External API Integration Tests
// File: ExternalAPIIntegrationTests.swift
// Purpose: Test integration with REAL external APIs
// WARNING: These tests require internet connection and hit real APIs
// Run these: Manually before releases, or nightly in CI/CD

import Testing
import Foundation
@testable import InigoVIP

// MARK: - Real API Integration Tests

@Suite("Real API Integration Tests - REQUIRES INTERNET", .tags(.externalAPI, .slow))
struct RealAPIIntegrationTests {
    
    // MARK: - JSONPlaceholder API Tests
    
    @Test("Real API: Fetch photos from JSONPlaceholder")
    func testRealAPIFetchPhotos() async throws {
        // Arrange
        let networkService = NetworkService()  // ✅ Real service, not mock
        
        // Act
        let transactions = try await networkService.fetchTransactions()
        
        // Assert
        #expect(transactions.count > 0, "Should fetch real data from API")
        #expect(transactions.count <= 20, "API is configured to return 20 items")
        
        // Verify data structure from real API
        let firstTransaction = transactions.first
        #expect(firstTransaction?.id.isEmpty == false, "Should have valid ID")
        #expect(firstTransaction?.description.isEmpty == false, "Should have description from API")
        #expect(firstTransaction?.thumbnailUrl?.isEmpty == false, "Should have thumbnail URL")
        
        // Verify URL is valid
        if let urlString = firstTransaction?.thumbnailUrl,
           let url = URL(string: urlString) {
            #expect(url.scheme == "https", "Should use HTTPS")
            #expect(url.host?.contains("placeholder") == true, "Should be from placeholder domain")
        }
    }
    
    @Test("Real API: Returns expected number of items")
    func testRealAPIItemCount() async throws {
        // Arrange
        let networkService = NetworkService()
        
        // Act
        let transactions = try await networkService.fetchTransactions()
        
        // Assert
        #expect(transactions.count == 20, "Should return exactly 20 items as configured")
    }
    
    @Test("Real API: Data consistency across multiple calls")
    func testRealAPIConsistency() async throws {
        // Arrange
        let networkService = NetworkService()
        
        // Act - Make multiple calls
        let call1 = try await networkService.fetchTransactions()
        let call2 = try await networkService.fetchTransactions()
        
        // Assert - JSONPlaceholder returns consistent data
        #expect(call1.count == call2.count, "API should return consistent count")
        
        // IDs should be same (JSONPlaceholder is deterministic)
        let ids1 = Set(call1.map { $0.id })
        let ids2 = Set(call2.map { $0.id })
        #expect(ids1 == ids2, "Should return same IDs across calls")
    }
    
    @Test("Real API: Response time is acceptable")
    func testRealAPIPerformance() async throws {
        // Arrange
        let networkService = NetworkService()
        
        // Act
        let startTime = Date()
        _ = try await networkService.fetchTransactions()
        let duration = Date().timeIntervalSince(startTime)
        
        // Assert
        #expect(duration < 10.0, "API should respond in <10 seconds, took \(duration)s")
        
        print("📊 Real API response time: \(String(format: "%.2f", duration))s")
    }
    
    @Test("Real API: Returns valid JSON structure")
    func testRealAPIJSONStructure() async throws {
        // Arrange
        let url = URL(string: "https://jsonplaceholder.typicode.com/photos?_limit=5")!
        
        // Act
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Assert HTTP response
        let httpResponse = response as? HTTPURLResponse
        #expect(httpResponse?.statusCode == 200, "Should return 200 OK")
        
        // Assert JSON structure
        let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        #expect(json != nil, "Should be valid JSON array")
        #expect(json?.count == 5, "Should return requested limit")
        
        // Verify expected fields exist
        let firstItem = json?.first
        #expect(firstItem?["id"] != nil, "Should have id field")
        #expect(firstItem?["title"] != nil, "Should have title field")
        #expect(firstItem?["thumbnailUrl"] != nil, "Should have thumbnailUrl field")
    }
    
    @Test("Real API: All transactions have valid data")
    func testRealAPIDataValidation() async throws {
        // Arrange
        let networkService = NetworkService()
        
        // Act
        let transactions = try await networkService.fetchTransactions()
        
        // Assert - All items have required fields
        for transaction in transactions {
            #expect(transaction.id.isEmpty == false, "ID should not be empty")
            #expect(transaction.description.isEmpty == false, "Description should not be empty")
            #expect(transaction.amount != 0, "Amount should not be zero")
            #expect(transaction.category.isEmpty == false, "Category should not be empty")
        }
    }
    
    @Test("Real API: Categories are assigned correctly")
    func testRealAPICategoryAssignment() async throws {
        // Arrange
        let networkService = NetworkService()
        let validCategories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]
        
        // Act
        let transactions = try await networkService.fetchTransactions()
        
        // Assert - All categories are valid
        for transaction in transactions {
            #expect(validCategories.contains(transaction.category),
                   "Category '\(transaction.category)' should be valid")
        }
    }
    
    @Test("Real API: Income/Expense distribution is logical")
    func testRealAPIIncomeExpenseDistribution() async throws {
        // Arrange
        let networkService = NetworkService()
        
        // Act
        let transactions = try await networkService.fetchTransactions()
        
        // Assert - Should have both income and expenses
        let incomes = transactions.filter { $0.amount > 0 }
        let expenses = transactions.filter { $0.amount < 0 }
        
        #expect(incomes.count > 0, "Should have at least some income transactions")
        #expect(expenses.count > 0, "Should have at least some expense transactions")
        
        print("📊 Income: \(incomes.count), Expenses: \(expenses.count)")
    }
    
    @Test("Real API: Thumbnail URLs have correct format")
    func testRealAPIThumbnailURLFormat() async throws {
        // Arrange
        let networkService = NetworkService()
        
        // Act
        let transactions = try await networkService.fetchTransactions()
        
        // Assert - Verify URL format (but don't try to load the image)
        guard let firstThumbnailUrl = transactions.first?.thumbnailUrl,
              let url = URL(string: firstThumbnailUrl) else {
            Issue.record("First transaction should have valid thumbnail URL")
            return
        }
        
        // Just verify it's a valid URL format
        #expect(url.scheme == "https", "Should use HTTPS")
        #expect(url.host != nil, "Should have a host")
        
        // Note: via.placeholder.com URLs may not actually load images
        // This is OK - we're just testing that the API returns valid URL strings
        print("📸 Thumbnail URL format: \(firstThumbnailUrl)")
    }
    
    // MARK: - Worker Integration with Real API
    
    @Test("TransactionWorker with real NetworkService")
    func testWorkerWithRealAPI() async throws {
        // Arrange
        let realNetwork = NetworkService()
        let cache = CacheService()
        let worker = TransactionWorker(
            networkService: realNetwork,  // ✅ Real API
            cacheService: cache
        )
        
        // Act
        let transactions = try await worker.fetchTransactions()
        
        // Assert
        #expect(transactions.count > 0, "Should fetch real transactions through worker")
    }
    
    @MainActor
    @Test("Full VIP stack with real API")
    func testFullVIPStackWithRealAPI() async throws {
        // Arrange - Full stack with real network
        let realNetwork = NetworkService()
        let worker = TransactionWorker(
            networkService: realNetwork,  // ✅ Real API
            cacheService: CacheService()
        )
        let interactor = TransactionListInteractor(
            transactionWorker: worker,
            analyticsWorker: MockAnalyticsWorker()  // Still mock analytics
        )
        let presenter = TransactionListPresenter()
        let viewController = MockTransactionListViewController()
        
        interactor.presenter = presenter
        presenter.viewController = viewController
        
        // Act
        await interactor.fetchTransactions()
        
        // Assert
        #expect(viewController.displayTransactionsCalled == true,
               "Should complete full VIP flow with real API")
        #expect(viewController.receivedViewModel?.transactions.count ?? 0 > 0,
               "Should receive real data through VIP stack")
        
        // Verify formatting was applied
        let displayed = viewController.receivedViewModel?.transactions.first
        #expect(displayed?.amount.contains("€") == true,
               "Presenter should format real data")
    }
}

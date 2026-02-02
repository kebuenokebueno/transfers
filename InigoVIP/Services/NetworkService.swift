//
//  NetworkService.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//
import Foundation


public protocol NetworkServiceProtocol {
    func fetchTransactions() async throws -> [Transfer]
}

actor NetworkService: NetworkServiceProtocol{
    func fetchTransactions() async throws -> [Transfer] {
        // Llamada real a JSONPlaceholder Photos API
        let url = URL(string: "https://jsonplaceholder.typicode.com/photos?_limit=20")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let photos = try JSONDecoder().decode([PhotoAPI].self, from: data)
        
        // Mapear fotos a transacciones
        return photos.map { photo in
            let isIncome = photo.id % 3 == 0  // Cada 3ra es income
            let amount = isIncome
                ? Double.random(in: 500...3000)
                : -Double.random(in: 10...200)
            
            let category = mapCategory(for: photo.id)
            
            return Transfer(
                id: "\(photo.id)",
                amount: amount,
                description: photo.title.capitalized,
                date: randomDate(),
                category: category,
                thumbnailUrl: photo.thumbnailUrl,
             )
        }
    }
    
    private func mapCategory(for id: Int) -> String {
        let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]
        return categories[id % categories.count]
    }
    
    private func randomDate() -> Date {
        let daysAgo = Int.random(in: 0...30)
        return Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
    }
}

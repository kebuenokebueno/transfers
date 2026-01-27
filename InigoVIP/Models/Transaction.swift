//
//  Transaction.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation


struct Transfer: Identifiable, Codable, Equatable {
    let id: String
    let amount: Double
    let description: String
    let date: Date
    let category: String
}

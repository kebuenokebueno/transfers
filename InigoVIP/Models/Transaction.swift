//
//  Transaction.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation


struct Transfer: Identifiable, Codable, Equatable {
    let id: String
    var amount: Double
    var description: String
    let date: Date
    var category: String
    var isEditing: Bool = false
}

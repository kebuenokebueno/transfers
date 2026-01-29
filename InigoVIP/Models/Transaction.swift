//
//  Transaction.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation


public struct Transfer: Identifiable, Codable, Equatable {
    public let id: String
    var amount: Double
    var description: String
    let date: Date
    var category: String
    let thumbnailUrl: String?  // URL de la imagen de la API
    var isEditing: Bool = false
}

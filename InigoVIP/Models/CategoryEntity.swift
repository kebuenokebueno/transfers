//
//  CategoryEntity.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import UIKit
import SwiftData

@Model
final class CategoryEntity {
    @Attribute(.unique) var id: String
    var name: String
    var icon: String
    var color: String
    var userId: String
    
    @Relationship var transactions: [Transfer]?
    
    init(id: String, name: String, icon: String, color: String, userId: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.userId = userId
    }
}

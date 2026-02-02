//
//  TagEntity.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftData

@Model
final class TagEntity {
    @Attribute(.unique) var id: String
    var name: String
    var userId: String
    
    init(id: String, name: String, userId: String) {
        self.id = id
        self.name = name
        self.userId = userId
    }
}

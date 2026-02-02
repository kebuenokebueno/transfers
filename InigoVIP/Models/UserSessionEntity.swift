//
//  UserSessionEntity.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftData

@Model
final class UserSessionEntity {
    @Attribute(.unique) var userId: String
    var email: String
    var name: String
    var lastLoginDate: Date
    var deviceId: String
    
    init(userId: String, email: String, name: String, deviceId: String) {
        self.userId = userId
        self.email = email
        self.name = name
        self.lastLoginDate = Date()
        self.deviceId = deviceId
    }
}

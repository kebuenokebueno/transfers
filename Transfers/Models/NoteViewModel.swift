//
//  File.swift
//  Transfers
//
//  Created by Inigo on 6/2/26.
//

import Foundation


struct NoteViewModel: Identifiable {
    let id: String
    let amount: String
    let description: String
    let date: String
    let category: String
    let isPositive: Bool
    let syncStatus: String
}

//
//  TKQRModel.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import Foundation

struct TKQRItem: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var label: String
    let createdAt: Date

    init(id: UUID = UUID(), text: String, label: String = "", createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.label = label.isEmpty ? text : label
        self.createdAt = createdAt
    }
}

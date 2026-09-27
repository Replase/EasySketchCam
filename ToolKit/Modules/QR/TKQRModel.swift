//
//  TKQRModel.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import Foundation

// MARK: - QR Type

enum TKQRType: String, Codable, CaseIterable, Identifiable {
    case url      = "URL"
    case wifi     = "WiFi"
    case email    = "Email"
    case phone    = "Teléfono"
    case sms      = "SMS"
    case text     = "Texto"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .url:   return "link"
        case .wifi:  return "wifi"
        case .email: return "envelope"
        case .phone: return "phone"
        case .sms:   return "message"
        case .text:  return "doc.text"
        }
    }
}

// MARK: - QR Item

struct TKQRItem: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var label: String
    var type: TKQRType
    let createdAt: Date

    init(id: UUID = UUID(), text: String, label: String = "", type: TKQRType = .url, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.label = label.isEmpty ? text : label
        self.type = type
        self.createdAt = createdAt
    }
}

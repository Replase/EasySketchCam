//
//  TKAppColorTheme.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import SwiftUI

enum TKAppColorTheme: String, CaseIterable, Identifiable {
    case blue
    case purple
    case green
    case orange
    case pink
    case red

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .blue:   return "Azul"
        case .purple: return "Morado"
        case .green:  return "Verde"
        case .orange: return "Naranja"
        case .pink:   return "Rosa"
        case .red:    return "Rojo"
        }
    }

    var color: Color {
        switch self {
        case .blue:   return .blue
        case .purple: return .purple
        case .green:  return .green
        case .orange: return .orange
        case .pink:   return .pink
        case .red:    return .red
        }
    }
}

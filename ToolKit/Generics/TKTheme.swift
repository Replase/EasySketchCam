//
//  TKTheme.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import SwiftUI

/// Sistema de diseño centralizado de la app.
/// Todos los módulos deben referenciar colores y estilos desde aquí.
enum TKTheme {

    // MARK: - Background

    /// Fondo principal de todas las pantallas
    static var background: Color { Color(.systemGroupedBackground) }

    /// Fondo secundario (cards, secciones)
    static var secondaryBackground: Color { Color(.secondarySystemGroupedBackground) }

    // MARK: - Text

    static var primaryText: Color { Color(.label) }
    static var secondaryText: Color { Color(.secondaryLabel) }

    // MARK: - Accent / Tint

    /// Color de acento configurable por el usuario. Lee de UserDefaults automáticamente.
    static var accent: Color {
        let raw = UserDefaults.standard.string(forKey: "TKAppColorTheme") ?? ""
        return TKAppColorTheme(rawValue: raw)?.color ?? .blue
    }
}

// MARK: - View Modifiers

extension View {

    /// Aplica el fondo estándar de pantalla completa de la app.
    func tkBackground() -> some View {
        self.background(TKTheme.background.ignoresSafeArea())
    }
}

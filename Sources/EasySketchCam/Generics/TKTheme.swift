//
//  TKTheme.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import SwiftUI
#if SKIP
import androidx.compose.material3.MaterialTheme
#endif

/// Sistema de diseño centralizado de la app.
/// Todos los módulos deben referenciar colores y estilos desde aquí.
enum TKTheme {

    // MARK: - Background

    /// Fondo principal de todas las pantallas
    static var background: Color {
        #if SKIP
        return Color(colorImpl: { MaterialTheme.colorScheme.surfaceContainerLow })
        #else
        return Color(.systemGroupedBackground)
        #endif
    }

    /// Fondo secundario (cards, secciones)
    static var secondaryBackground: Color {
        #if SKIP
        return Color(colorImpl: { MaterialTheme.colorScheme.surfaceContainerHighest })
        #else
        return Color(.secondarySystemGroupedBackground)
        #endif
    }

    // MARK: - Text

    static var primaryText: Color { Color.primary }
    static var secondaryText: Color { Color.secondary }

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

extension View {

    /// Hace que toda el área del view responda a toques (iOS).
    /// `contentShape` no existe en Skip; en Android el área ya es tocable completa.
    @ViewBuilder
    func tkTapArea() -> some View {
        #if SKIP
        self
        #else
        self.contentShape(Rectangle())
        #endif
    }
}

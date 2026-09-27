//
//  ContentView.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import SwiftUI

struct ContentView: View {

    @AppStorage("TKAppColorTheme") private var colorThemeRaw: String = TKAppColorTheme.blue.rawValue

    private var tintColor: Color {
        TKAppColorTheme(rawValue: colorThemeRaw)?.color ?? .blue
    }

    var body: some View {
        TabView {
            Tab("Bocetos", systemImage: TKSymbol.sketches) {
                TKHomeFactory.make()
            }
            Tab("Generar QR", systemImage: TKSymbol.qrCode) {
                TKQRView()
            }
            Tab("Configuración", systemImage: TKSymbol.settings) {
                TKSettingsFactory.makeView()
            }
        }
        .tint(tintColor)
    }
}

#if !SKIP
#Preview {
    ContentView()
}
#endif

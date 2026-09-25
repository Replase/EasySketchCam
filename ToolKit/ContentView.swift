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
            Tab("Bocetos", systemImage: "pencil.and.outline") {
                TKHomeFactory.make()
            }
            Tab("Generar QR", systemImage: "qrcode") {
                TKQRView()
            }
            Tab("Configuración", systemImage: "slider.horizontal.2.square") {
                TKSettingsFactory.makeView()
            }
        }
        .tint(tintColor)
    }
}

#Preview {
    ContentView()
}

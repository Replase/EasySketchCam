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
            TKHomeFactory.make()
                .tabItem { Label("Bocetos", systemImage: "pencil.and.outline") }
            TKQRView()
                .tabItem { Label("Generar QR", systemImage: "plus.circle.fill") }
            TKSettingsFactory.makeView()
                .tabItem { Label("Configuración", systemImage: "slider.horizontal.2.square") }
        }
        .tint(tintColor)
    }
}

#Preview {
    ContentView()
}

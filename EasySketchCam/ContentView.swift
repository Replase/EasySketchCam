//
//  ContentView.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            CFHomeFactory.make()
                .tabItem { Label("Inicio", systemImage: "house") }
        }
    }
}

#Preview {
    ContentView()
}

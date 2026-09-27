//
//  TKSettingsView.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import SwiftUI

struct TKSettingsView: View {

    @State private var router = TKMainRouter()
    @State private var viewModel: TKSettingsViewModel

    init(viewModel: TKSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        List {
            Section("Apariencia") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Color de la app")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // HStack en lugar de LazyVGrid: en Android no se puede anidar
                    // un grid lazy dentro de una List.
                    HStack(spacing: 0) {
                        ForEach(TKAppColorTheme.allCases) { theme in
                            colorOption(theme, viewModel: viewModel)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Configuración")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func colorOption(_ theme: TKAppColorTheme, viewModel: TKSettingsViewModel) -> some View {
        Button {
            viewModel.selectedColorTheme = theme
        } label: {
            ZStack {
                Circle()
                    .fill(theme.color)
                    .frame(width: 40, height: 40)

                if viewModel.selectedColorTheme == theme {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2.5)
                        .frame(width: 40, height: 40)
                    Image(systemName: TKSymbol.checkmark)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.white)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(theme.displayName)
    }
}

#if !SKIP
#Preview {
    TKSettingsFactory.makeView()
}
#endif

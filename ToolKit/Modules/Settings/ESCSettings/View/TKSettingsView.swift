//
//  TKSettingsView.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import SwiftUI

struct TKSettingsView: View {

    @StateObject private var router = TKMainRouter()
    @Environment(\.dismiss) private var dismiss
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

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(TKAppColorTheme.allCases) { theme in
                            colorOption(theme, viewModel: viewModel)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Configuración")
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
                        .strokeBorder(.white, lineWidth: 2.5)
                        .frame(width: 40, height: 40)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(theme.displayName)
    }
}

#Preview {
    TKSettingsFactory.makeView()
}

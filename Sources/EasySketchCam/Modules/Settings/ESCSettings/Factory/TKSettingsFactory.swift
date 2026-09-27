//
//  TKSettingsFactory.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import SwiftUI

@MainActor
enum TKSettingsFactory {

    static func makeView() -> TKSettingsView {
        let repository = TKSettingsRepository()
        let csu = TKSettingsCSU(repository: repository)
        let viewModel = TKSettingsViewModel(csu: csu)
        return TKSettingsView(viewModel: viewModel)
    }
}

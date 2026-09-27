//
//  TKSettingsViewModel.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import Foundation
import Observation

private let colorThemeKey = "TKAppColorTheme"

@MainActor
@Observable
final class TKSettingsViewModel {

    private let csu: any TKSettingsCSUProtocol

    var selectedColorTheme: TKAppColorTheme {
        didSet {
            UserDefaults.standard.set(selectedColorTheme.rawValue, forKey: colorThemeKey)
        }
    }

    init(csu: any TKSettingsCSUProtocol) {
        self.csu = csu
        let savedRaw = UserDefaults.standard.string(forKey: colorThemeKey) ?? ""
        self.selectedColorTheme = TKAppColorTheme(rawValue: savedRaw) ?? .blue
    }
}

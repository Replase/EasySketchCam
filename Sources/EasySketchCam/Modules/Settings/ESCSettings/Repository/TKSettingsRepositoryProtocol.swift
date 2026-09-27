//
//  TKSettingsRepositoryProtocol.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import Foundation

protocol TKSettingsRepositoryProtocol {
    func fetchItems() async throws -> [TKSettingsModel]
}

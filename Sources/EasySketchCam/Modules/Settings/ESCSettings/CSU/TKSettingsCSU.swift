//
//  TKSettingsCSU.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import Foundation

final class TKSettingsCSU: TKSettingsCSUProtocol {

    private let repository: any TKSettingsRepositoryProtocol

    init(repository: any TKSettingsRepositoryProtocol) {
        self.repository = repository
    }

    func fetchItems() async throws -> [TKSettingsModel] {
        // TODO: agrega aquí la lógica de negocio/orquestación entre repositorios
        try await repository.fetchItems()
    }
}

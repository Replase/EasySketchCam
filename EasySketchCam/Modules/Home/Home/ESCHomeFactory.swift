//
//  ESCHomeFactory.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

struct ESCHomeFactory {
    static func make() -> ESCHomeView {
        let viewModel = ESCHomeViewModel()
        return ESCHomeView(viewModel: viewModel)
    }
}

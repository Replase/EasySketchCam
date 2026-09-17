//
//  CFHomeFactory.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

struct CFHomeFactory {
    static func make() -> CFHomeView {
        let viewModel = CFHomeViewModel()
        return CFHomeView(viewModel: viewModel)
    }
}

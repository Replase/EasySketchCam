//
//  TKHomeFactory.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

struct TKHomeFactory {
    static func make() -> TKHomeView {
        let viewModel = TKHomeViewModel()
        return TKHomeView(viewModel: viewModel)
    }
}

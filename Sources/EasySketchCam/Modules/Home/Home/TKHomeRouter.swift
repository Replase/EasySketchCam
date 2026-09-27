//
//  TKHomeRouter.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import SwiftUI

enum TKHomeRouter: Hashable {
    case sketch(item: CalcaImagen)
}

extension TKHomeRouter {

    @ViewBuilder
    func destination() -> some View {
        switch self {
        case .sketch(let item):
            TKSketchFactory.make(image: item.image)
        }
    }
}

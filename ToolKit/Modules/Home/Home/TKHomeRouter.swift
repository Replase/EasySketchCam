//
//  TKHomeRouter.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import UIKit
import SwiftUI

enum TKHomeRouter: Hashable {
    case sketch(image: UIImage)
}

extension TKHomeRouter {

    func destination() -> some View {
        switch self {
        case .sketch(image: let image):
            return TKSketchFactory.make(image: image)
        }
    }
}

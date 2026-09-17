//
//  ESCHomeRouter.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import UIKit
import SwiftUI

enum ESCHomeRouter: Hashable {
    case sketch(image: UIImage)
}

extension ESCHomeRouter {
    
    func destination() -> some View {
        switch self {
        case .sketch(image: let image):
            return ESCSketchFactory.make(image: image)
        }
    }
    
}

//
//  TKSketchFactory.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import UIKit

struct TKSketchFactory {
    static func make(image: UIImage) -> TKSketchView {
        return TKSketchView(image: image)
    }
}

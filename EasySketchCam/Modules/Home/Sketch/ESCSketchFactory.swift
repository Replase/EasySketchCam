//
//  ESCSketchFactory.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import UIKit

struct ESCSketchFactory {
    static func make(image: UIImage) -> ESCSketchView {
        return ESCSketchView(image: image)
    }
}

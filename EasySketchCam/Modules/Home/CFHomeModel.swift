//
//  CFHomeModel.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import Foundation
import UIKit

struct CalcaImagen: Identifiable, Hashable {
    let id = UUID()
    let dataName: String
    let image: UIImage
}

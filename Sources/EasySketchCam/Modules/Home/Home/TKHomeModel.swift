//
//  TKHomeModel.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import Foundation
import SwiftUI

struct CalcaImagen: Identifiable, Hashable {
    let id: UUID
    let dataName: String
    let image: UIImage

    init(dataName: String, image: UIImage) {
        self.id = UUID()
        self.dataName = dataName
        self.image = image
    }

    static func == (lhs: CalcaImagen, rhs: CalcaImagen) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

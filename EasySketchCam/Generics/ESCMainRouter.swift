//
//  ESCMainRouter.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ESCMainRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func push<T: Hashable>(_ route: T) {
        path.append(route)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func popLast(_ k: Int) {
        path.removeLast(min(k, path.count))
    }
}

//
//  TKMainRouter.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import Foundation
import Observation
import SwiftUI

/// Router basado en `NavigationPath`.
/// Usa `@Observable` (en lugar de Combine/`ObservableObject`) porque es lo que
/// Skip soporta de forma nativa en iOS y Android.
@MainActor
@Observable
final class TKMainRouter {
    var path = NavigationPath()

    func push(_ route: any Hashable) {
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

//
//  EasySketchCamApp.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import Foundation
import OSLog
import SwiftUI

/// Logger compartido del módulo (Xcode console en iOS, `adb logcat` en Android).
let logger: Logger = Logger(subsystem: "ToolKit.ToolKit", category: "EasySketchCam")

/// Vista raíz compartida. La cargan los entry points de cada plataforma:
/// `Darwin/Sources/Main.swift` (iOS) y `Android/app/src/main/kotlin/Main.kt` (Android).
public struct EasySketchCamRootView: View {
    public init() {
    }

    public var body: some View {
        ContentView()
    }
}

/// Callbacks globales del ciclo de vida de la app, invocados desde ambas plataformas.
public final class EasySketchCamAppDelegate: Sendable {
    public static let shared = EasySketchCamAppDelegate()

    private init() {
    }

    public func onInit() {
        logger.debug("onInit")
    }

    public func onLaunch() {
        logger.debug("onLaunch")
    }

    public func onResume() {
        logger.debug("onResume")
    }

    public func onPause() {
        logger.debug("onPause")
    }

    public func onStop() {
        logger.debug("onStop")
    }

    public func onDestroy() {
        logger.debug("onDestroy")
    }

    public func onLowMemory() {
        logger.debug("onLowMemory")
    }
}

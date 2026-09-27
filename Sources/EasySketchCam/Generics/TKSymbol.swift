//
//  TKSymbol.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 26/09/26.
//

import Foundation

/// Nombres de íconos por plataforma.
///
/// En iOS se usan SF Symbols. En Android, SkipUI solo traduce un subconjunto de
/// SF Symbols a Material Icons, así que aquí se usa directamente el nombre del
/// ícono Material (p. ej. "Icons.Outlined.Create"), que SkipUI también acepta
/// en `Image(systemName:)`, `Label(_:systemImage:)` y `Tab(_:systemImage:)`.
///
/// Para usar un ícono que no exista en Material core, exporta el SF Symbol como
/// SVG y agrégalo a `Resources/Module.xcassets` con el mismo nombre
/// (ver https://skip.dev/docs/components/image/).
enum TKSymbol {

    private static func pick(_ ios: String, _ android: String) -> String {
        #if SKIP
        return android
        #else
        return ios
        #endif
    }

    // MARK: - Tabs
    static var sketches: String { pick("pencil.and.outline", "Icons.Outlined.Create") }
    static var qrCode: String { pick("qrcode", "Icons.Outlined.QrCodeScanner") }
    static var settings: String { pick("slider.horizontal.2.square", "Icons.Outlined.Settings") }

    // MARK: - Home
    static var gallery: String { pick("photo.on.rectangle", "Icons.Outlined.AddCircle") }
    static var camera: String { pick("camera", "Icons.Outlined.Add") }
    static var add: String { pick("plus", "Icons.Outlined.Add") }
    static var emptySketches: String { pick("photo.stack", "Icons.Outlined.Create") }
    static var trace: String { pick("pencil.line", "Icons.Outlined.Edit") }

    // MARK: - Sketch
    static var close: String { pick("xmark", "Icons.Outlined.Close") }
    static var locked: String { pick("lock.fill", "Icons.Filled.Lock") }
    static var unlocked: String { pick("lock.open.fill", "Icons.Outlined.Lock") }
    static var reset: String { pick("arrow.counterclockwise", "Icons.Outlined.Refresh") }

    // MARK: - QR
    static var chevronRight: String { pick("chevron.right", "Icons.Outlined.KeyboardArrowRight") }
    static var trash: String { pick("trash", "Icons.Outlined.Delete") }
    static var edit: String { pick("pencil", "Icons.Outlined.Edit") }
    static var share: String { pick("square.and.arrow.up", "Icons.Outlined.Share") }
    static var checkmark: String { pick("checkmark", "Icons.Outlined.Check") }
}

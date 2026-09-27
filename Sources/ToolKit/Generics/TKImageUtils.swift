//
//  TKImageUtils.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 26/09/26.
//

import Foundation

enum TKImageUtils {

    /// Normaliza una imagen importada.
    ///
    /// En Android las fotos de cámara vienen con la rotación en EXIF (que
    /// `BitmapFactory` ignora) y suelen pesar varios MB, así que se rotan y se
    /// reducen a máx. 2048 px (ver `Skip/TKAndroidImage.kt`).
    /// En iOS `UIImage` ya respeta EXIF, así que se devuelven los mismos bytes.
    static func normalizedImageData(_ data: Data) -> Data {
        #if SKIP
        if let bytes = tkNormalizeImage(data.kotlin(), 2048) {
            return Data(platformValue: bytes)
        }
        return data
        #else
        return data
        #endif
    }
}

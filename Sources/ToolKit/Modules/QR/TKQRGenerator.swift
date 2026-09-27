//
//  TKQRGenerator.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 26/09/26.
//

import Foundation
import SwiftUI
#if !SKIP
import CoreImage.CIFilterBuiltins
#endif

/// Genera imágenes de códigos QR en ambas plataformas.
/// - iOS: CoreImage (`CIFilter.qrCodeGenerator`).
/// - Android: ZXing (ver `Skip/TKAndroidImage.kt`).
enum TKQRGenerator {

    /// Lado en píxeles de la imagen generada en Android.
    private static let androidSize = 600

    static func image(for text: String) -> UIImage? {
        guard !text.isEmpty else { return nil }
        #if SKIP
        guard let data = pngData(for: text) else { return nil }
        return UIImage(data: data)
        #else
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"

        guard let ciImage = filter.outputImage else { return nil }

        let scale: CGFloat = 10
        let transformed = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(transformed, from: transformed.extent) else { return nil }
        return UIImage(cgImage: cgImage)
        #endif
    }

    #if SKIP
    /// PNG del QR (solo Android; en iOS se comparte con `ShareLink`).
    static func pngData(for text: String) -> Data? {
        guard let bytes = tkQRCodePNG(text, androidSize) else { return nil }
        return Data(platformValue: bytes)
    }

    /// Abre la hoja de compartir de Android con la imagen del QR.
    static func share(text: String, title: String) {
        guard let data = pngData(for: text) else { return }
        tkShareImage(data.kotlin(), title)
    }
    #endif
}

/// Caché simple para no regenerar el QR de cada fila en cada render.
final class TKQRImageCache {
    private var images: [String: UIImage] = [:]

    func image(for text: String) -> UIImage? {
        if let cached = images[text] {
            return cached
        }
        guard let generated = TKQRGenerator.image(for: text) else { return nil }
        images[text] = generated
        return generated
    }
}

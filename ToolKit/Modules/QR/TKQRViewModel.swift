//
//  TKQRViewModel.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import Foundation
import Observation
import CoreImage.CIFilterBuiltins
import UIKit
import SwiftUI

private let storageKey = "TKSavedQRItems"

@MainActor
@Observable
final class TKQRViewModel {

    var items: [TKQRItem] = []

    init() {
        load()
    }

    // MARK: - CRUD

    func save(text: String, label: String) {
        let item = TKQRItem(text: text, label: label)
        items.insert(item, at: 0)
        persist()
    }

    func update(_ item: TKQRItem, text: String, label: String) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].text = text
        items[index].label = label.isEmpty ? text : label
        persist()
    }

    func delete(_ item: TKQRItem) {
        items.removeAll { $0.id == item.id }
        persist()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        persist()
    }

    // MARK: - QR Image Generation

    func generateImage(for text: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"

        guard let ciImage = filter.outputImage else { return nil }

        let scale: CGFloat = 10
        let transformed = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(transformed, from: transformed.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    // MARK: - Persistence

    private func persist() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([TKQRItem].self, from: data) else { return }
        items = decoded
    }
}

//
//  TKQRViewModel.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import Foundation
import Observation
import SwiftUI

private let storageKey = "TKSavedQRItems"

@MainActor
@Observable
final class TKQRViewModel {

    var items: [TKQRItem] = []

    private let imageCache = TKQRImageCache()

    init() {
        load()
    }

    // MARK: - CRUD

    func save(text: String, label: String, type: TKQRType) {
        let item = TKQRItem(text: text, label: label, type: type)
        items.insert(item, at: 0)
        persist()
    }

    func update(_ item: TKQRItem, text: String, label: String, type: TKQRType) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].text = text
        items[index].label = label.isEmpty ? text : label
        items[index].type = type
        persist()
    }

    func delete(_ item: TKQRItem) {
        items.removeAll { $0.id == item.id }
        persist()
    }

    // MARK: - QR Image Generation

    func generateImage(for text: String) -> UIImage? {
        imageCache.image(for: text)
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

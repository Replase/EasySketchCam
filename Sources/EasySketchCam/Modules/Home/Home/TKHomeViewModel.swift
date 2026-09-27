//
//  TKHomeViewModel.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import Foundation
import Observation
import SwiftUI
#if !SKIP
import PhotosUI
#endif

private let imagesStorageKey = "lista_imagenes_calcafacil"

@MainActor
@Observable
final class TKHomeViewModel {
    var selectedImage: UIImage?
    var showCamera = false
    var showGallery = false
    var showActionSheet = false
    var listImages: [CalcaImagen] = []

    /// URL que entrega el media picker de SkipKit (Android).
    var pickedImageURL: URL?

    private func getPathDocuments() -> URL {
        URL.documentsDirectory
    }

    // MARK: - Import

    #if !SKIP
    /// iOS: imagen elegida con `PhotosPicker`.
    func saveImage(_ image: PhotosPickerItem?) {
        Task {
            guard let data = try? await image?.loadTransferable(type: Data.self) else { return }
            await MainActor.run {
                self.addImage(data: data)
            }
        }
    }

    /// iOS: foto tomada con la cámara (`UIImagePickerController`).
    func savePhoto(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1) else { return }
        addImage(data: imageData)
    }
    #endif

    /// Android (y cualquier plataforma): importa una imagen a partir de una URL
    /// `file://` o `content://` devuelta por el media picker.
    func importImage(from url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            logger.error("No se pudo leer la imagen en \(url.absoluteString)")
            return
        }
        addImage(data: TKImageUtils.normalizedImageData(data))
    }

    private func addImage(data: Data) {
        guard let uiImage = UIImage(data: data),
              let dataName = saveImageInApp(data: data) else { return }
        listImages.append(CalcaImagen(dataName: dataName, image: uiImage))
        persistNames()
    }

    func saveImageInApp(data: Data) -> String? {
        let name = "\(UUID().uuidString).jpg"
        let dataPath = getPathDocuments().appendingPathComponent(name)

        do {
            try data.write(to: dataPath)
            return name
        } catch {
            logger.error("Error al guardar imagen en disco: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Load / Delete

    func getImageSaved() {
        let saveNames = loadNames()
        guard !saveNames.isEmpty else { return }

        var listImagesSaved: [CalcaImagen] = []

        for name in saveNames {
            let dataPath = getPathDocuments().appendingPathComponent(name)
            if let dataImage = try? Data(contentsOf: dataPath),
               let uiImage = UIImage(data: dataImage) {
                listImagesSaved.append(CalcaImagen(dataName: name, image: uiImage))
            }
        }

        self.listImages = listImagesSaved
    }

    func deleteImage(image: CalcaImagen) {
        let dataPath = getPathDocuments().appendingPathComponent(image.dataName)
        do {
            if FileManager.default.fileExists(atPath: dataPath.path) {
                try FileManager.default.removeItem(at: dataPath)
            }
        } catch {
            logger.error("Error al eliminar archivo del almacenamiento: \(error.localizedDescription)")
        }

        listImages.removeAll { $0.id == image.id }
        persistNames()
    }

    // Los nombres se guardan como JSON (Data): en Android, UserDefaults no
    // soporta arreglos (`stringArray(forKey:)` no existe y `set([String])` se ignora).
    private func persistNames() {
        let names = listImages.map { $0.dataName }
        if let data = try? JSONEncoder().encode(names) {
            UserDefaults.standard.set(data, forKey: imagesStorageKey)
        }
    }

    private func loadNames() -> [String] {
        if let data = UserDefaults.standard.data(forKey: imagesStorageKey),
           let names = try? JSONDecoder().decode([String].self, from: data) {
            return names
        }
        #if !SKIP
        // Compatibilidad con versiones anteriores de iOS, que guardaban un [String].
        if let legacy = UserDefaults.standard.stringArray(forKey: imagesStorageKey) {
            return legacy
        }
        #endif
        return []
    }
}

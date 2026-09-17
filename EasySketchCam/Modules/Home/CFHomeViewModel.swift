//
//  CFHomeViewModel.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import Combine
import Foundation
import Observation
import UIKit
import PhotosUI
import SwiftUI

@MainActor
@Observable
class CFHomeViewModel {
    var selectedImage: UIImage?
    var showCamera = false
    var showGallery = false
    var showActionSheet = false
    var listImages: [CalcaImagen] = []
    
    
    private func getPathDocuments() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveImage(_ image: PhotosPickerItem?) {
        Task {
            var newImages: [CalcaImagen] = []
            if let data = try? await image?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                if let dataName = saveImageInApp(data: data) {
                    newImages.append(CalcaImagen(dataName: dataName, image: uiImage))
                }
            }
            await MainActor.run {
                self.listImages.append(contentsOf: newImages)
                let savedNames = self.listImages.map { $0.dataName }
                UserDefaults.standard.set(savedNames, forKey: "lista_imagenes_calcafacil")
                
            }
        }
    }
    
    func savePhoto(_ image: UIImage) {
        Task {
            var newImages: [CalcaImagen] = []
            if let imageData = image.jpegData(compressionQuality: 1) {
                if let dataName = saveImageInApp(data: imageData) {
                    newImages.append(CalcaImagen(dataName: dataName, image: image))
                }
            }
            
            await MainActor.run {
                self.listImages.append(contentsOf: newImages)
                let savedNames = self.listImages.map { $0.dataName }
                UserDefaults.standard.set(savedNames, forKey: "lista_imagenes_calcafacil")
                
            }
        }
    }
    
    func saveImageInApp(data: Data) -> String? {
        let name = "\(UUID().uuidString).jpg"
        let dataPath = getPathDocuments().appendingPathComponent(name)
        
        do {
            try data.write(to: dataPath)
            return name
        } catch {
            print("Error al guardar imagen en disco: \(error)")
            return nil
        }
    }
    
    func getImageSaved() {
        guard let saveNames = UserDefaults.standard.stringArray(forKey: "lista_imagenes_calcafacil") else { return }
        
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
            print("Error al eliminar archivo del almacenamiento: \(error)")
        }
        
        listImages.removeAll { $0.id == image.id }
        
        let newListImage = listImages.map { $0.dataName }
        UserDefaults.standard.set(newListImage, forKey: "lista_imagenes_calcafacil")
    }
    
}

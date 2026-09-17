//
//  ESCHomeView.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import SwiftUI
import PhotosUI

struct ESCHomeView: View {
    @StateObject private var router = ESCMainRouter()
    @State private var viewModel: ESCHomeViewModel
    @State private var fotoSeleccionada: PhotosPickerItem? = nil
    
    private let columnas = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    init(viewModel: ESCHomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                VStack(spacing: 40) {
                    HStack(alignment: .center, spacing: 40) {
                        PhotosPicker(
                            selection: $fotoSeleccionada,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Label("Galeria", systemImage: "photo")
                        }
                        .buttonStyle(.glass)
                        .foregroundStyle(.red)
                        Button("Camara", systemImage: "camera", action: {
                            viewModel.showCamera.toggle()
                        })
                        .buttonStyle(.glass)
                        .foregroundStyle(.red)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    LazyVGrid(columns: columnas, spacing: 10) {
                        ForEach(viewModel.listImages, id: \.self) { image in
                            Image(uiImage: image.image)
                                .resizable()
                                .scaledToFill()
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .aspectRatio(1, contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .contextMenu {
                                    Button {
                                        router.push(ESCHomeRouter.sketch(image: image.image))
                                    } label: {
                                        Label("Calcar Dibujo", systemImage: "pencil.line")
                                    }
                                    Divider()
                                    Button(role: .destructive) {
                                        viewModel.deleteImage(image: image)
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .onChange(of: fotoSeleccionada) { _, _ in
                    viewModel.saveImage(fotoSeleccionada)
                    fotoSeleccionada = nil
                }
                .onChange(of: viewModel.selectedImage) { _, newPhoto in
                    if let newPhoto {
                        viewModel.savePhoto(newPhoto)
                    }
                }
            }
            .navigationTitle("EasySketchCam")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(isPresented: $viewModel.showCamera) {
                CameraPicker(image: $viewModel.selectedImage)
                    .ignoresSafeArea()
            }
            .onAppear {
                viewModel.getImageSaved()
            }
            .navigationDestination(for: ESCHomeRouter.self, destination: { route in
                route.destination()
            })
        }
    }
}

// MARK: - Selector de Cámara con UIImagePickerController
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ContentView()
}

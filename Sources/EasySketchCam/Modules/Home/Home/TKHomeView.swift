//
//  TKHomeView.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import SwiftUI
#if SKIP
import SkipKit
#else
import PhotosUI
#endif

struct TKHomeView: View {
    @State private var router = TKMainRouter()
    @State private var viewModel: TKHomeViewModel
    #if !SKIP
    @State private var fotoSeleccionada: PhotosPickerItem? = nil
    #endif
    @AppStorage("TKAppColorTheme") private var colorThemeRaw: String = TKAppColorTheme.blue.rawValue

    private var accentColor: Color {
        TKAppColorTheme(rawValue: colorThemeRaw)?.color ?? .blue
    }

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    init(viewModel: TKHomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .background(TKTheme.background)
                .navigationTitle("Bocetos")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        addButtons
                    }
                }
                .onAppear {
                    viewModel.getImageSaved()
                }
                .navigationDestination(for: TKHomeRouter.self) { route in
                    route.destination()
                }
                .modifier(TKImageSourcesModifier(viewModel: viewModel))
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.listImages.isEmpty {
            ScrollView {
                emptyState
            }
        } else {
            photoGrid
        }
    }

    // MARK: - Toolbar

    @ViewBuilder
    private var addButtons: some View {
        #if SKIP
        // Android: un solo botón "+" con menú, que es el patrón habitual en Material.
        Menu {
            Button {
                viewModel.showGallery = true
            } label: {
                Label("Galería", systemImage: TKSymbol.gallery)
            }
            Button {
                viewModel.showCamera = true
            } label: {
                Label("Cámara", systemImage: TKSymbol.camera)
            }
        } label: {
            Label("Agregar", systemImage: TKSymbol.add)
        }
        .tint(accentColor)
        #else
        PhotosPicker(
            selection: $fotoSeleccionada,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Label("Galería", systemImage: TKSymbol.gallery)
        }
        .tint(accentColor)
        .onChange(of: fotoSeleccionada) { _, _ in
            viewModel.saveImage(fotoSeleccionada)
            fotoSeleccionada = nil
        }

        Button {
            viewModel.showCamera.toggle()
        } label: {
            Label("Cámara", systemImage: TKSymbol.camera)
        }
        .tint(accentColor)
        #endif
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: TKSymbol.emptySketches)
                .font(.system(size: 64))
                .foregroundStyle(accentColor.opacity(0.6))
            Text("Sin bocetos")
                .font(.title3.bold())
            Text("Agrega una foto desde la galería o toma una con la cámara")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    // MARK: - Photo Grid

    /// Cuadrícula de 3 columnas con celdas cuadradas.
    /// En Android un `LazyVGrid` dentro de `ScrollView` debe ser su único hijo,
    /// por eso ya no se usa `GeometryReader` para calcular el tamaño de celda.
    @ViewBuilder
    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewModel.listImages) { item in
                    TKPhotoCell(item: item, accentColor: accentColor) {
                        router.push(TKHomeRouter.sketch(item: item))
                    } onDelete: {
                        viewModel.deleteImage(image: item)
                    }
                }
            }
        }
    }
}

// MARK: - Image sources (cámara / galería)

/// Conecta las fuentes de imágenes de cada plataforma con el view model.
/// - iOS: cámara con `UIImagePickerController` (la galería usa `PhotosPicker` en la toolbar).
/// - Android: cámara y galería con el media picker de SkipKit.
private struct TKImageSourcesModifier: ViewModifier {
    @Bindable var viewModel: TKHomeViewModel

    func body(content: Content) -> some View {
        #if SKIP
        content
            .withMediaPicker(type: MediaPickerType.library, isPresented: $viewModel.showGallery, selectedImageURL: $viewModel.pickedImageURL)
            .withMediaPicker(type: MediaPickerType.camera, isPresented: $viewModel.showCamera, selectedImageURL: $viewModel.pickedImageURL)
            .onChange(of: viewModel.pickedImageURL) { _, newURL in
                if let newURL = newURL {
                    viewModel.importImage(from: newURL)
                    viewModel.pickedImageURL = nil
                }
            }
        #else
        content
            .fullScreenCover(isPresented: $viewModel.showCamera) {
                CameraPicker(image: $viewModel.selectedImage)
                    .ignoresSafeArea()
            }
            .onChange(of: viewModel.selectedImage) { _, newPhoto in
                if let newPhoto = newPhoto {
                    viewModel.savePhoto(newPhoto)
                    viewModel.selectedImage = nil
                }
            }
        #endif
    }
}

// MARK: - Photo Cell

private struct TKPhotoCell: View {

    let item: CalcaImagen
    let accentColor: Color
    let onSketch: () -> Void
    let onDelete: () -> Void

    @State private var showActions = false

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Image(uiImage: item.image)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .tkTapArea()
            .onTapGesture {
                showActions = true
            }
            .confirmationDialog("¿Qué quieres hacer?", isPresented: $showActions, titleVisibility: .visible) {
                Button {
                    onSketch()
                } label: {
                    Label("Calcar dibujo", systemImage: TKSymbol.trace)
                }
                Button("Eliminar", role: .destructive) {
                    onDelete()
                }
            }
            .contextMenu {
                Button {
                    onSketch()
                } label: {
                    Label("Calcar dibujo", systemImage: TKSymbol.trace)
                }
                Divider()
                Button("Eliminar", role: .destructive) {
                    onDelete()
                }
            }
    }
}

#if !SKIP
// MARK: - Camera Picker (iOS)

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

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) { self.parent = parent }

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
#endif

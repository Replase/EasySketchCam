//
//  TKHomeView.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import SwiftUI
import PhotosUI

struct TKHomeView: View {
    @StateObject private var router = TKMainRouter()
    @State private var viewModel: TKHomeViewModel
    @State private var fotoSeleccionada: PhotosPickerItem? = nil
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
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                if viewModel.listImages.isEmpty {
                    emptyState
                } else {
                    photoGrid
                }
            }
            .background(TKTheme.background)
            .navigationTitle("Bocetos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarActions }
            .fullScreenCover(isPresented: $viewModel.showCamera) {
                CameraPicker(image: $viewModel.selectedImage)
                    .ignoresSafeArea()
            }
            .onAppear {
                viewModel.getImageSaved()
            }
            .onChange(of: fotoSeleccionada) { _, _ in
                viewModel.saveImage(fotoSeleccionada)
                fotoSeleccionada = nil
            }
            .onChange(of: viewModel.selectedImage) { _, newPhoto in
                if let newPhoto {
                    viewModel.savePhoto(newPhoto)
                }
            }
            .navigationDestination(for: TKHomeRouter.self) { route in
                route.destination()
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarActions: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            PhotosPicker(
                selection: $fotoSeleccionada,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("Galería", systemImage: "photo.on.rectangle")
            }
            .tint(accentColor)

            Button {
                viewModel.showCamera.toggle()
            } label: {
                Label("Cámara", systemImage: "camera")
            }
            .tint(accentColor)
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.stack")
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

    @ViewBuilder
    private var photoGrid: some View {
        GeometryReader { geo in
            let cellSize = (geo.size.width - 4) / 3  // 3 celdas, 2 gaps de 2pt
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewModel.listImages, id: \.self) { item in
                    TKPhotoCell(item: item, cellSize: cellSize, accentColor: accentColor) {
                        router.push(TKHomeRouter.sketch(image: item.image))
                    } onDelete: {
                        viewModel.deleteImage(image: item)
                    }
                }
            }
        }
        .frame(minHeight: cellMinHeight)
    }

    // Altura mínima del grid para que GeometryReader tenga espacio suficiente
    private var cellMinHeight: CGFloat {
        let rows = ceil(Double(viewModel.listImages.count) / 3.0)
        let screenWidth = UIScreen.main.bounds.width
        let cellSize = (screenWidth - 4) / 3
        return CGFloat(rows) * cellSize + CGFloat(rows - 1) * 2
    }
}

// MARK: - Photo Cell

private struct TKPhotoCell: View {

    let item: CalcaImagen
    let cellSize: CGFloat
    let accentColor: Color
    let onSketch: () -> Void
    let onDelete: () -> Void

    @State private var showActions = false

    var body: some View {
        Image(uiImage: item.image)
            .resizable()
            .scaledToFill()
            .frame(width: cellSize, height: cellSize)
            .clipped()
            .contentShape(Rectangle())
            .onTapGesture {
                showActions = true
            }
            .confirmationDialog("¿Qué quieres hacer?", isPresented: $showActions, titleVisibility: .visible) {
                Button {
                    onSketch()
                } label: {
                    Label("Calcar dibujo", systemImage: "pencil.line")
                }
                Button("Eliminar", role: .destructive) {
                    onDelete()
                }
            }
            .contextMenu {
                Button {
                    onSketch()
                } label: {
                    Label("Calcar dibujo", systemImage: "pencil.line")
                }
                Divider()
                Button("Eliminar", role: .destructive) {
                    onDelete()
                }
            } preview: {
                Image(uiImage: item.image)
                    .resizable()
                    .scaledToFit()
            }
    }
}

// MARK: - Camera Picker

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

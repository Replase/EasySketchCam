//
//  TKQRView.swift
//  ToolKit
//
//  Created by Alan Emiliano Ramirez Ayala on 25/09/26.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Root View

struct TKQRView: View {

    @AppStorage("TKAppColorTheme") private var colorThemeRaw: String = TKAppColorTheme.blue.rawValue
    @State private var viewModel = TKQRViewModel()
    @State private var showCreate = false
    @State private var itemToEdit: TKQRItem? = nil

    private var accentColor: Color {
        TKAppColorTheme(rawValue: colorThemeRaw)?.color ?? .blue
    }

    var body: some View {
        NavigationStack {
            list
            .background(TKTheme.background)
            .navigationTitle("Códigos QR")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreate = true
                    } label: {
                        Label("Nuevo QR", systemImage: "plus")
                    }
                    .tint(accentColor)
                }
            }
            .sheet(isPresented: $showCreate) {
                TKQRFormView(accentColor: accentColor) { text, label in
                    viewModel.save(text: text, label: label)
                }
            }
            .sheet(item: $itemToEdit) { item in
                TKQRFormView(accentColor: accentColor, existing: item) { text, label in
                    viewModel.update(item, text: text, label: label)
                }
            }
        }
    }

    // MARK: - List (with built-in empty state)

    @ViewBuilder
    private var list: some View {
        List {
            ForEach(viewModel.items) { item in
                TKQRRowView(item: item, accentColor: accentColor, viewModel: viewModel) {
                    itemToEdit = item
                }
            }
            .onDelete { offsets in
                viewModel.delete(at: offsets)
            }
        }
        .overlay {
            if viewModel.items.isEmpty {
                ContentUnavailableView {
                    Label("Sin códigos QR", systemImage: "qrcode")
                } description: {
                    Text("Toca + para crear tu primer código QR")
                }
                .foregroundStyle(accentColor, .secondary)
            }
        }
    }
}

// MARK: - Row

private struct TKQRRowView: View {

    let item: TKQRItem
    let accentColor: Color
    let viewModel: TKQRViewModel
    let onEdit: () -> Void

    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            HStack(spacing: 16) {
                if let img = viewModel.generateImage(for: item.text) {
                    Image(uiImage: img)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52)
                        .padding(6)
                        .background(.white, in: RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.label)
                        .font(.headline)
                        .lineLimit(1)
                    Text(item.text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                viewModel.delete(item)
            } label: {
                Label("Eliminar", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                onEdit()
            } label: {
                Label("Editar", systemImage: "pencil")
            }
            .tint(accentColor)
        }
        .sheet(isPresented: $showDetail) {
            TKQRDetailView(item: item, accentColor: accentColor)
        }
    }
}

// MARK: - Detail Sheet

private struct TKQRDetailView: View {

    let item: TKQRItem
    let accentColor: Color
    @Environment(\.dismiss) private var dismiss

    private var qrImage: UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(item.text.utf8)
        filter.correctionLevel = "M"
        guard let ci = filter.outputImage else { return nil }
        let scaled = ci.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let cg = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cg)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    if let img = qrImage {
                        Image(uiImage: img)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 260, height: 260)
                            .padding(20)
                            .background(.white, in: RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)

                        ShareLink(
                            item: Image(uiImage: img),
                            preview: SharePreview(item.label, image: Image(uiImage: img))
                        ) {
                            Label("Compartir QR", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(accentColor)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contenido")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(item.text)
                            .font(.body)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(TKTheme.secondaryBackground, in: RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .background(TKTheme.background)
            .navigationTitle(item.label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Cerrar") { dismiss() }
                        .tint(accentColor)
                }
            }
        }
    }
}

// MARK: - Form (Create / Edit)

struct TKQRFormView: View {

    let accentColor: Color
    var existing: TKQRItem? = nil
    let onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @State private var label: String = ""
    @State private var qrPreview: UIImage? = nil
    @FocusState private var focusedField: Field?

    private enum Field { case label, text }

    private var isEditing: Bool { existing != nil }
    private var canSave: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    formFields
                    if let qrPreview {
                        previewSection(qrPreview)
                    }
                }
                .padding()
            }
            .background(TKTheme.background)
            .navigationTitle(isEditing ? "Editar QR" : "Nuevo QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(text.trimmingCharacters(in: .whitespacesAndNewlines),
                               label.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                    .tint(accentColor)
                    .disabled(!canSave)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Listo") { focusedField = nil }
                }
            }
            .onAppear {
                if let existing {
                    text = existing.text
                    label = existing.label
                    updatePreview()
                }
            }
            .onChange(of: text) { _, _ in updatePreview() }
        }
    }

    @ViewBuilder
    private var formFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Nombre (opcional)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Mi QR", text: $label)
                    .focused($focusedField, equals: .label)
                    .padding(12)
                    .background(TKTheme.secondaryBackground, in: RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("URL o texto")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("https://ejemplo.com", text: $text)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .text)
                    .padding(12)
                    .background(TKTheme.secondaryBackground, in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(20)
        .background(TKTheme.secondaryBackground, in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func previewSection(_ img: UIImage) -> some View {
        VStack(spacing: 12) {
            Text("Vista previa")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(uiImage: img)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(16)
                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        }
        .padding(20)
        .background(TKTheme.secondaryBackground, in: RoundedRectangle(cornerRadius: 16))
        .transition(.scale(scale: 0.95).combined(with: .opacity))
    }

    private func updatePreview() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { qrPreview = nil; return }

        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(trimmed.utf8)
        filter.correctionLevel = "M"
        guard let ci = filter.outputImage else { return }
        let scaled = ci.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let cg = context.createCGImage(scaled, from: scaled.extent) else { return }
        withAnimation(.spring(duration: 0.3)) {
            qrPreview = UIImage(cgImage: cg)
        }
    }
}

#Preview {
    TKQRView()
}

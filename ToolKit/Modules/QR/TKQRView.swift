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
                TKQRFormView(accentColor: accentColor) { text, label, type in
                    viewModel.save(text: text, label: label, type: type)
                }
            }
            .sheet(item: $itemToEdit) { item in
                TKQRFormView(accentColor: accentColor, existing: item) { text, label, type in
                    viewModel.update(item, text: text, label: label, type: type)
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
                    HStack(spacing: 6) {
                        Image(systemName: item.type.systemImage)
                            .font(.caption2)
                            .foregroundStyle(accentColor)
                        Text(item.type.rawValue)
                            .font(.caption2)
                            .foregroundStyle(accentColor)
                    }
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
                        HStack(spacing: 6) {
                            Image(systemName: item.type.systemImage)
                                .foregroundStyle(accentColor)
                            Text(item.type.rawValue)
                                .foregroundStyle(accentColor)
                        }
                        .font(.caption)

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
    let onSave: (String, String, TKQRType) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: TKQRType = .url
    @State private var label: String = ""

    // URL
    @State private var urlText: String = ""

    // WiFi
    @State private var wifiSSID: String = ""
    @State private var wifiPassword: String = ""
    @State private var wifiSecurity: WifiSecurity = .wpa
    @State private var wifiHidden: Bool = false

    // Email
    @State private var emailAddress: String = ""
    @State private var emailSubject: String = ""
    @State private var emailBody: String = ""

    // Phone
    @State private var phoneNumber: String = ""

    // SMS
    @State private var smsNumber: String = ""
    @State private var smsMessage: String = ""

    // Text
    @State private var plainText: String = ""

    @State private var qrPreview: UIImage? = nil
    @FocusState private var focusedField: Bool

    private enum WifiSecurity: String, CaseIterable, Identifiable {
        case wpa = "WPA/WPA2"
        case wep = "WEP"
        case none = "Sin contraseña"
        var id: String { rawValue }
        var qrValue: String {
            switch self {
            case .wpa:  return "WPA"
            case .wep:  return "WEP"
            case .none: return "nopass"
            }
        }
    }

    private var isEditing: Bool { existing != nil }

    private var generatedText: String {
        switch selectedType {
        case .url:
            return urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        case .wifi:
            let ssid = wifiSSID.trimmingCharacters(in: .whitespacesAndNewlines)
            let pass = wifiPassword.trimmingCharacters(in: .whitespacesAndNewlines)
            let hidden = wifiHidden ? "true" : "false"
            return "WIFI:S:\(ssid);T:\(wifiSecurity.qrValue);P:\(pass);H:\(hidden);;"
        case .email:
            let addr = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
            let subj = emailSubject.trimmingCharacters(in: .whitespacesAndNewlines)
            let body = emailBody.trimmingCharacters(in: .whitespacesAndNewlines)
            var result = "mailto:\(addr)"
            var params: [String] = []
            if !subj.isEmpty { params.append("subject=\(subj)") }
            if !body.isEmpty { params.append("body=\(body)") }
            if !params.isEmpty { result += "?" + params.joined(separator: "&") }
            return result
        case .phone:
            return "tel:\(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines))"
        case .sms:
            let num = smsNumber.trimmingCharacters(in: .whitespacesAndNewlines)
            let msg = smsMessage.trimmingCharacters(in: .whitespacesAndNewlines)
            return msg.isEmpty ? "sms:\(num)" : "sms:\(num)?body=\(msg)"
        case .text:
            return plainText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private var canSave: Bool { !generatedText.isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    typePicker
                    labelField
                    typeFields
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
                        onSave(generatedText, label.trimmingCharacters(in: .whitespacesAndNewlines), selectedType)
                        dismiss()
                    }
                    .tint(accentColor)
                    .disabled(!canSave)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Listo") { focusedField = false }
                }
            }
            .onAppear { loadExisting() }
            .onChange(of: generatedText) { _, _ in updatePreview() }
            .onChange(of: selectedType) { _, _ in updatePreview() }
        }
    }

    // MARK: - Type Picker

    private var typePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tipo de QR")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(TKQRType.allCases) { type in
                        Button {
                            withAnimation(.spring(duration: 0.25)) {
                                selectedType = type
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: type.systemImage)
                                    .font(.title3)
                                Text(type.rawValue)
                                    .font(.caption2)
                            }
                            .frame(width: 70, height: 60)
                            .foregroundStyle(selectedType == type ? .white : accentColor)
                            .background(
                                selectedType == type ? accentColor : accentColor.opacity(0.12),
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(16)
        .background(TKTheme.secondaryBackground, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Label Field

    private var labelField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Nombre (opcional)")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Mi QR", text: $label)
                .focused($focusedField)
                .padding(12)
                .background(TKTheme.secondaryBackground, in: RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(TKTheme.secondaryBackground, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Type-specific Fields

    @ViewBuilder
    private var typeFields: some View {
        switch selectedType {
        case .url:    urlFields
        case .wifi:   wifiFields
        case .email:  emailFields
        case .phone:  phoneFields
        case .sms:    smsFields
        case .text:   textFields
        }
    }

    private var urlFields: some View {
        formSection {
            fieldRow(title: "URL o texto", placeholder: "https://ejemplo.com") {
                TextField("https://ejemplo.com", text: $urlText)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focusedField)
            }
        }
    }

    private var wifiFields: some View {
        formSection {
            fieldRow(title: "Nombre de red (SSID)", placeholder: "Mi WiFi") {
                TextField("Mi WiFi", text: $wifiSSID)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focusedField)
            }
            Divider()
            fieldRow(title: "Contraseña", placeholder: "Contraseña") {
                SecureField("Contraseña", text: $wifiPassword)
                    .focused($focusedField)
            }
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                Text("Seguridad")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("Seguridad", selection: $wifiSecurity) {
                    ForEach(WifiSecurity.allCases) { sec in
                        Text(sec.rawValue).tag(sec)
                    }
                }
                .pickerStyle(.segmented)
            }
            Divider()
            Toggle("Red oculta", isOn: $wifiHidden)
                .tint(accentColor)
        }
    }

    private var emailFields: some View {
        formSection {
            fieldRow(title: "Dirección de email", placeholder: "correo@ejemplo.com") {
                TextField("correo@ejemplo.com", text: $emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focusedField)
            }
            Divider()
            fieldRow(title: "Asunto (opcional)", placeholder: "Asunto") {
                TextField("Asunto", text: $emailSubject)
                    .focused($focusedField)
            }
            Divider()
            fieldRow(title: "Mensaje (opcional)", placeholder: "Mensaje") {
                TextField("Mensaje", text: $emailBody)
                    .focused($focusedField)
            }
        }
    }

    private var phoneFields: some View {
        formSection {
            fieldRow(title: "Número de teléfono", placeholder: "+52 55 1234 5678") {
                TextField("+52 55 1234 5678", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .focused($focusedField)
            }
        }
    }

    private var smsFields: some View {
        formSection {
            fieldRow(title: "Número de teléfono", placeholder: "+52 55 1234 5678") {
                TextField("+52 55 1234 5678", text: $smsNumber)
                    .keyboardType(.phonePad)
                    .focused($focusedField)
            }
            Divider()
            fieldRow(title: "Mensaje (opcional)", placeholder: "Hola!") {
                TextField("Hola!", text: $smsMessage)
                    .focused($focusedField)
            }
        }
    }

    private var textFields: some View {
        formSection {
            fieldRow(title: "Texto", placeholder: "Escribe cualquier texto...") {
                TextField("Escribe cualquier texto...", text: $plainText, axis: .vertical)
                    .lineLimit(3...6)
                    .focused($focusedField)
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func formSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            content()
        }
        .padding(16)
        .background(TKTheme.secondaryBackground, in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func fieldRow<Content: View>(title: String, placeholder: String, @ViewBuilder field: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            field()
                .padding(12)
                .background(TKTheme.background, in: RoundedRectangle(cornerRadius: 10))
        }
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

    // MARK: - Logic

    private func loadExisting() {
        guard let existing else { return }
        selectedType = existing.type
        label = existing.label
        // Restore raw text into the correct field
        switch existing.type {
        case .url:   urlText = existing.text
        case .text:  plainText = existing.text
        case .phone: phoneNumber = String(existing.text.dropFirst(4)) // drop "tel:"
        case .wifi:
            // Parse WIFI:S:ssid;T:security;P:pass;H:hidden;;
            let raw = existing.text
            wifiSSID = extract(key: "S", from: raw)
            wifiPassword = extract(key: "P", from: raw)
            let t = extract(key: "T", from: raw)
            wifiSecurity = WifiSecurity.allCases.first { $0.qrValue == t } ?? .wpa
            wifiHidden = extract(key: "H", from: raw) == "true"
        case .email:
            // mailto:addr?subject=subj&body=body
            let raw = existing.text
            if let atRange = raw.range(of: "mailto:") {
                let rest = String(raw[atRange.upperBound...])
                let parts = rest.components(separatedBy: "?")
                emailAddress = parts[0]
                if parts.count > 1 {
                    let params = parts[1].components(separatedBy: "&")
                    for param in params {
                        let kv = param.components(separatedBy: "=")
                        if kv.count == 2 {
                            if kv[0] == "subject" { emailSubject = kv[1] }
                            if kv[0] == "body" { emailBody = kv[1] }
                        }
                    }
                }
            }
        case .sms:
            let raw = existing.text
            if let atRange = raw.range(of: "sms:") {
                let rest = String(raw[atRange.upperBound...])
                let parts = rest.components(separatedBy: "?body=")
                smsNumber = parts[0]
                if parts.count > 1 { smsMessage = parts[1] }
            }
        }
        updatePreview()
    }

    private func extract(key: String, from string: String) -> String {
        // Matches key:value; in WiFi QR strings
        let pattern = "\(key):([^;]*)"
        guard let range = string.range(of: pattern, options: .regularExpression) else { return "" }
        let match = String(string[range])
        return String(match.dropFirst(key.count + 1))
    }

    private func updatePreview() {
        let trimmed = generatedText
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

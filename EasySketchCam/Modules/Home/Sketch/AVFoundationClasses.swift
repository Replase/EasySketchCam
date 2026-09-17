//
//  AVFoundationClasses.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import SwiftUI
import AVFoundation

// MARK: - UIView que hospeda la capa de preview de la cámara

final class ESCCameraPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

// MARK: - Representable que arma y controla la sesión de captura

struct ESCCameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> ESCCameraPreviewUIView {
        let view = ESCCameraPreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: ESCCameraPreviewUIView, context: Context) {}
}

// MARK: - Controlador de la sesión de captura (maneja permisos, start/stop)

@Observable
final class ESCCameraSessionController {
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "cf.camera.session.queue")

    func start() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted, let self else { return }
            self.configureSession()
            self.queue.async {
                self.session.startRunning()
            }
        }
    }

    func stop() {
        queue.async { [weak self] in
            self?.session.stopRunning()
        }
    }

    private func configureSession() {
        guard session.inputs.isEmpty else { return }

        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)
        session.commitConfiguration()
    }
}

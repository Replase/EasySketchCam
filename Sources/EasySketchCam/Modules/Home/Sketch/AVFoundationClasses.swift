//
//  AVFoundationClasses.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

// Solo iOS: en Android la vista previa de cámara se implementa con CameraX
// en `Skip/TKAndroidCamera.kt`.
#if !SKIP
#if os(iOS)
import SwiftUI
import AVFoundation

// MARK: - UIView que hospeda la capa de preview de la cámara

final class TKCameraPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

// MARK: - Representable que arma y controla la sesión de captura

struct TKCameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> TKCameraPreviewUIView {
        let view = TKCameraPreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: TKCameraPreviewUIView, context: Context) {}
}

// MARK: - Controlador de la sesión de captura (maneja permisos, start/stop)

@Observable
final class TKCameraSessionController {
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "tk.camera.session.queue")

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
#endif
#endif

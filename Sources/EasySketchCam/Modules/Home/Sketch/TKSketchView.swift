//
//  TKSketchView.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import SwiftUI
#if SKIP
import androidx.compose.foundation.layout.fillMaxSize
#endif

struct TKSketchView: View {
    let image: UIImage

    #if !SKIP
    @State private var cameraController = TKCameraSessionController()
    #endif
    @State private var opacidad: Double = 0.5
    @Environment(\.dismiss) private var dismiss

    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var isLocked: Bool = false

    // Estado temporal de los gestos. Skip Lite no soporta `@GestureState`,
    // así que se usa `@State` y se reinicia en `onEnded`.
    @State private var dragTranslation: CGSize = .zero
    @State private var magnifyBy: CGFloat = 1.0

    var body: some View {
        ZStack {
            cameraPreview
                .ignoresSafeArea()

            overlayImage

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: TKSymbol.close)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.black.opacity(0.4), in: Circle())
                    }

                    Spacer()

                    Button {
                        withAnimation(.spring) {
                            isLocked.toggle()
                        }
                    } label: {
                        Image(systemName: isLocked ? TKSymbol.locked : TKSymbol.unlocked)
                            .font(.title2)
                            .foregroundStyle(isLocked ? Color.yellow : Color.white)
                            .padding()
                            .background(.black.opacity(0.4), in: Circle())
                    }

                    Button {
                        withAnimation(.spring) {
                            offset = .zero
                            scale = 1.0
                        }
                    } label: {
                        Image(systemName: TKSymbol.reset)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.black.opacity(0.4), in: Circle())
                    }
                }
                .padding()

                Spacer()

                VStack(spacing: 8) {
                    HStack {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 2)
                            .frame(width: 18, height: 18)
                        Slider(value: $opacidad, in: 0...1)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 18, height: 18)
                    }
                    .foregroundStyle(.white)
                    Text("Opacidad: \(Int(opacidad * 100))%")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding()
                .background(.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 16))
                .padding()
            }
        }
        .onAppear {
            startCamera()
        }
        .onDisappear {
            stopCamera()
        }
        .toolbar(.hidden, for: .navigationBar, .tabBar)
        .statusBarHidden()
    }

    // MARK: - Camera

    @ViewBuilder
    private var cameraPreview: some View {
        #if SKIP
        // CameraX (ver Skip/TKAndroidCamera.kt). Pide el permiso de cámara si hace falta.
        ComposeView { context in
            TKAndroidCameraPreview(modifier: context.modifier.fillMaxSize())
        }
        #else
        TKCameraPreviewView(session: cameraController.session)
        #endif
    }

    /// En iOS se controla la `AVCaptureSession`; en Android CameraX se liga al
    /// ciclo de vida del composable, así que no hace falta hacer nada.
    private func startCamera() {
        #if !SKIP
        cameraController.start()
        #endif
    }

    private func stopCamera() {
        #if !SKIP
        cameraController.stop()
        #endif
    }

    // MARK: - Overlay image

    @ViewBuilder
    private var overlayImage: some View {
        #if SKIP
        // En Android los gestos deben ir antes de `.offset` y se registran por separado.
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .opacity(opacidad)
            .scaleEffect(scale * magnifyBy)
            .gesture(dragGesture, isEnabled: !isLocked)
            .gesture(magnifyGesture, isEnabled: !isLocked)
            .offset(x: offset.width + dragTranslation.width, y: offset.height + dragTranslation.height)
        #else
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .opacity(opacidad)
            .scaleEffect(scale * magnifyBy)
            .offset(x: offset.width + dragTranslation.width, y: offset.height + dragTranslation.height)
            .gesture(dragGesture.simultaneously(with: magnifyGesture), isEnabled: !isLocked)
        #endif
    }

    // MARK: - Gestures

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragTranslation = value.translation
            }
            .onEnded { value in
                offset.width += value.translation.width
                offset.height += value.translation.height
                dragTranslation = .zero
            }
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                magnifyBy = value.magnification
            }
            .onEnded { value in
                scale = min(max(scale * value.magnification, 0.3), 5.0)
                magnifyBy = 1.0
            }
    }
}

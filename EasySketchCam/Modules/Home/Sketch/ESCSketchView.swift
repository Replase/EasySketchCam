//
//  ESCSketchView.swift
//  EasySketchCam
//
//  Created by Alan Emiliano Ramirez Ayala on 16/09/26.
//

import SwiftUI

struct ESCSketchView: View {
    let image: UIImage
    
    @State private var cameraController = ESCCameraSessionController()
    @State private var opacidad: Double = 0.5
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    
    @GestureState private var dragTranslation: CGSize = .zero
    @GestureState private var magnifyBy: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            ESCCameraPreviewView(session: cameraController.session)
                .ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .opacity(opacidad)
                .scaleEffect(scale * magnifyBy)
                .offset(
                    x: offset.width + dragTranslation.width,
                    y: offset.height + dragTranslation.height
                )
                .gesture(combinedGesture)
            
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.black.opacity(0.4), in: Circle())
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring) {
                            offset = .zero
                            scale = 1.0
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
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
                        Image(systemName: "circle.lefthalf.filled")
                        Slider(value: $opacidad, in: 0...1)
                        Image(systemName: "circle.fill")
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
            cameraController.start()
        }
        .onDisappear {
            cameraController.stop()
        }
        .statusBarHidden()
    }
    
    
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragTranslation) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                offset.width += value.translation.width
                offset.height += value.translation.height
            }
    }
    
    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .updating($magnifyBy) { value, state, _ in
                state = value
            }
            .onEnded { value in
                scale *= value
                scale = min(max(scale, 0.3), 5.0)
            }
    }
    
    private var combinedGesture: some Gesture {
        dragGesture.simultaneously(with: magnifyGesture)
    }
}

#Preview {
    ContentView()
}

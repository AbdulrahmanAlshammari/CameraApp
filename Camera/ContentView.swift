//
//  ContentView.swift
//  Camera
//
//  Created by ABDULRAHMAN AL-KHALED on 15/01/2024.
//

import AVFoundation
import SwiftUI

struct ContentView: View {
    @ObservedObject var vm = ContentViewModel()
    var body: some View {
        ZStack {
            if let cameraView = vm.preview {
                cameraView
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    Circle()
                        .fill(vm.isRecoding ? .red : .blue)
                        .frame(width: 8 * 10)
                        .onTapGesture {
                            vm.isRecoding ? vm.stopRecording() :
                                vm.startRecording()
                        }
                }
            } else {
                Text("No camera")
            }
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Preview

struct Preview: UIViewControllerRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    let gravity: AVLayerVideoGravity

    init(
        with session: AVCaptureSession,
        gravity: AVLayerVideoGravity
    ) {
        self.gravity = gravity
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        previewLayer.videoGravity = gravity
        uiViewController.view.layer.addSublayer(previewLayer)

        previewLayer.frame = uiViewController.view.bounds
    }

    func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: ()) {
        previewLayer.removeFromSuperlayer()
    }
}

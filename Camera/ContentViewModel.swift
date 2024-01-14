//
//  ContentViewModel.swift
//  Camera
//
//  Created by ABDULRAHMAN AL-KHALED on 15/01/2024.
//

import AVFoundation
import Foundation

class ContentViewModel: NSObject, ObservableObject {
    let session: AVCaptureSession
    @Published var preview: Preview?
    @Published var isRecoding = false

    override init() {
        session = AVCaptureSession()
        super.init()

        Task(priority: .background) {
            switch await AuthorizationChecker.checkCaptureAuthorizationStatus() {
            case .permitted:
                try session
                    .addMovieInput()
                    .addMovieFileOutput()
                    .startRunning()

                DispatchQueue.main.async {
                    self.preview = Preview(with: self.session, gravity: .resizeAspectFill)
                }

            case .notPermitted:
                break
            }
        }
    }

    func startRecording() {
        guard let output = session.movieFileOutput else {
            print("Cannot find movie file output")
            return
        }

        guard
            let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            print("Cannot access local file domain")
            return
        }
        isRecoding = true
        let fileName = UUID().uuidString
        let filePath = directoryPath
            .appendingPathComponent(fileName)
            .appendingPathExtension("mp4")

        output.startRecording(to: filePath, recordingDelegate: self)
    }

    func stopRecording() {
        guard let output = session.movieFileOutput else {
            print("Cannot find movie file output")
            return
        }
        isRecoding = false
        output.stopRecording()
    }
}

extension ContentViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("error with recoding")
            return
        }

        print("yay 🥳, finished recoding and your video saved in \(outputFileURL)")
    }
}

// MARK: - AVCaptureSession Extension

extension AVCaptureSession {
    var movieFileOutput: AVCaptureMovieFileOutput? {
        let output = outputs.first as? AVCaptureMovieFileOutput
        return output
    }

    func addMovieInput() throws -> Self {
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            throw VideoError.inputNotAdded
        }

        let videoInput = try AVCaptureDeviceInput(device: videoDevice)

        guard canAddInput(videoInput) else {
            throw VideoError.unableToAddInput
        }

        addInput(videoInput)

        return self
    }

    func addMovieFileOutput() throws -> Self {
        guard movieFileOutput == nil else {
            // return itself if output is already set
            return self
        }

        let fileOutput = AVCaptureMovieFileOutput()

        guard canAddOutput(fileOutput) else {
            throw VideoError.unableToAddOutput
        }

        addOutput(fileOutput)

        return self
    }
}

enum VideoError: Error {
    case inputNotAdded
    case unableToAddInput
    case unableToAddOutput
}

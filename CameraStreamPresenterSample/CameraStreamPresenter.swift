//
//  CameraStreamPresenter.swift
//  CameraStreamPresenterSample
//
//  Created by Nagamine Hiromasa on 2017/11/13.
//  Copyright © 2017 Nagamine Hiromasa. All rights reserved.
//

import Foundation
import UIKit
import AVKit

protocol CameraStreamPresenterDelegate {
    func didFinishCamera()
}

protocol CameraStreamPresenterProtocol: class {
    var delegate: CameraStreamPresenterDelegate? { set get }
    var isEditmode: Bool { get set }
    var imageURL: URL? { get set }
    var movieURL: URL? { get set }
    var isAuthorized: Bool { get }
    var session: AVCaptureSession { get }

    func configure(output: AVCapturePhotoOutput)
    func checkAuthorizationAVCapture()
    func start()
    func stop()

    func saveImage(image: UIImage) 
}

class CameraStreamPresenter: CameraStreamPresenterProtocol {

    var delegate: CameraStreamPresenterDelegate?
    var wireframe: CameraViewWireframeInput?
    var isEditmode: Bool = false
    var imageURL: URL?
    var movieURL: URL?
    var isAuthorized: Bool = false
    

    var session: AVCaptureSession = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: "session queue", attributes: [])

    func checkAuthorizationAVCapture() {
        self.sessionQueue.suspend()
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [unowned self] isSuccess in
                self.sessionQueue.resume()
                self.isAuthorized = true
            })

        default:
            break
        }

        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
    }

    func configure(output: AVCapturePhotoOutput) {
        self.configureSession()
        self.addPhotoOutput(output: output)
        self.session.commitConfiguration()
    }

    func start() {
        self.session.startRunning()
    }

    func stop() {
        self.session.stopRunning()
    }

    private func addPhotoOutput(output: AVCapturePhotoOutput) {
        if self.session.canAddOutput(output) {
            self.session.addOutput(output)
        }
    }

    private func configureSession() {
        session.beginConfiguration()

        guard let device = AVCaptureDevice.default(for: .video),
            let deviceInput = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(deviceInput) else {
                return
        }

        session.addInput(deviceInput)
    }

    func saveImage(image: UIImage) {
        self.wireframe?.saveImage(image: image)
    }
}

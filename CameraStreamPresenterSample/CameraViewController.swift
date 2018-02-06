//
//  CameraViewController.swift
//  CameraStreamPresenterSample
//
//  Created by Nagamine Hiromasa on 2017/11/13.
//  Copyright © 2017 Nagamine Hiromasa. All rights reserved.
//

import Foundation
import UIKit
import Photos
import AVFoundation
import MobileCoreServices

import TOCropViewController

class PreviewView: UIImageView {

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        let previewlayer = layer as! AVCaptureVideoPreviewLayer
        previewlayer.videoGravity = .resizeAspectFill
        return previewlayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .black
    }

    override class var layerClass : AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
}

class CameraViewController: UIViewController {

    // Camera Interface
    var presenter: CameraStreamPresenterProtocol
    let preview = PreviewView()

    let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: "session queue", attributes: [])
    let videoOutput = AVCapturePhotoOutput()


    lazy var rightBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "take", style: .plain, target: self, action: #selector(takeImage))
        return button
    }()

    init(presenter: CameraStreamPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkAuthorizationAVCapture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureViews()
        self.configureSession()
        self.addPhotoOutput()
        self.session.commitConfiguration()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session.startRunning()
    }

    // Configuration
    private func configureViews() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem

        let previewWidth = self.view.bounds.width
        let previewHeight = previewWidth * 3.0 / 4.0
        self.preview.frame = CGRect(x: 0, y: 100, width: previewWidth, height: previewHeight)
        self.view.addSubview(self.preview)
    }

    private func configureSession() {
        session.beginConfiguration()
//        session.sessionPreset = .high
        guard let device = AVCaptureDevice.default(for: .video),
            let deviceInput = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(deviceInput) else {
                return
        }

        session.addInput(deviceInput)
    }

    private func addPhotoOutput() {

        if self.session.canAddOutput(videoOutput) {
            self.session.addOutput(videoOutput)
        }

        self.preview.videoPreviewLayer.session = self.session
    }

    private func checkAuthorizationAVCapture() {
        self.sessionQueue.suspend()
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: break

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [unowned self] isSuccess in
                self.sessionQueue.resume()
            })

        default:
            break
        }

        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
    }

    @objc private func takeImage() {
        DispatchQueue.global(qos: .default).async(execute: { () -> Void in
            let settingsForMonitoring = AVCapturePhotoSettings()
            settingsForMonitoring.flashMode = .auto
            settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
            settingsForMonitoring.isHighResolutionPhotoEnabled = false

            self.videoOutput.capturePhoto(with: settingsForMonitoring, delegate: self)
//            imageOutput.captureStillImageAsynchronously(from: connection!) { (buffer, error) -> Void in
//
//                self.stopCamera()
//
//                guard let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!),
//                    let image = UIImage(data: data),
//                    let cgImage = image.cgImage,
//                    let delegate = self.delegate,
//                    let videoLayer = self.videoLayer else {
//
//                        return
//                }
//
//                let rect   = videoLayer.metadataOutputRectConverted(fromLayerRect: videoLayer.bounds)
//                let width  = CGFloat(cgImage.width)
//                let height = CGFloat(cgImage.height)
//
//                let cropRect = CGRect(x: rect.origin.x * width,
//                                      y: rect.origin.y * height,
//                                      width: rect.size.width * width,
//                                      height: rect.size.height * height)
//
//                guard let img = cgImage.cropping(to: cropRect) else {
//
//                    return
//                }
//
//                let croppedUIImage = UIImage(cgImage: img, scale: 1.0, orientation: image.imageOrientation)
        })
    }

    func saveImage(image: UIImage) -> URL? {
        let fileManager = FileManager.default
        var newAssetURL: URL? = nil
        
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let filePath = "\(rootPath)/image.jpg"
        
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        if fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil) {
            print("Created file")
        }
        
        if (fileManager.fileExists(atPath: filePath)){
            newAssetURL = URL(fileURLWithPath: filePath)
        }
        
        return newAssetURL
    }

    func saveVideo(fileUrl: URL) -> URL? {
        let fileManager = FileManager.default
        var newAssetURL: URL? = nil
        
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let filePath = "\(rootPath)/video.mp4"
        
        let data = try! Data(contentsOf: fileUrl)
        
        if fileManager.createFile(atPath: filePath, contents: data, attributes: nil) {
            print("Created file")
        }
        
        if (fileManager.fileExists(atPath: filePath)){
            newAssetURL = URL(fileURLWithPath: filePath)
        }
        
        return newAssetURL
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
//    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {

        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            preview.image = UIImage(data: photoData!)
        }
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            
            let vc = TOCropViewController(croppingStyle: .default, image: pickedImage)
            vc.aspectRatioLockEnabled = true
            vc.resetAspectRatioEnabled = false
            vc.aspectRatioPickerButtonHidden = true
            vc.delegate = self
            vc.setAspectRatioPresent(.preset4x3, animated: true)
            self.presenter.isEditmode = true
            self.present(vc, animated: true, completion: nil)
        }
        else if let movieURL = info[UIImagePickerControllerMediaURL] as? URL {
            self.presenter.movieURL = self.saveVideo(fileUrl: movieURL)
            self.presenter.delegate?.didFinishCamera()
            
            self.presenter.isEditmode = true
            
            picker.dismiss(animated: true, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.presenter.isEditmode = true
        picker.dismiss(animated: true, completion: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}

extension CameraViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropImageToRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: {
            self.presenter.imageURL = self.saveImage(image: cropViewController.image)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        if cancelled {
            self.presenter.isEditmode = false
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
}


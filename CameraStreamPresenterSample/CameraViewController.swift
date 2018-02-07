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
import StoryboardBuilder_iOS

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
    var videoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()

    lazy var rightBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(dismissVC))
        return button
    }()

    lazy var takeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.backgroundColor = .white
        button.layer.cornerRadius = 30.0

        let borderView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        borderView.center = button.center
        borderView.layer.borderColor = UIColor.black.cgColor
        borderView.layer.borderWidth = 2.0
        borderView.layer.cornerRadius = 22.5
        borderView.backgroundColor = .clear
        borderView.isUserInteractionEnabled = false
        button.addSubview(borderView)

        button.addTarget(self, action: #selector(take), for: .touchUpInside)
        return button
    }()

    init(presenter: CameraStreamPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
//        self.edgesForExtendedLayout = []
        self.view.backgroundColor = .black
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.presenter.checkAuthorizationAVCapture()
        self.configureViews()
        self.presenter.configure(output: videoOutput)
        self.preview.videoPreviewLayer.session = presenter.session
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.stop()
    }

    // Configuration
    private func configureViews() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem

        let previewWidth = self.view.bounds.width
        let previewHeight = previewWidth * 4.0 / 3.0
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height ?? 44.0
        self.preview.frame = CGRect(x: 0, y: navigationBarHeight + statusBarHeight, width: previewWidth, height: previewHeight)
        self.view.addSubview(self.preview)

        self.takeButton.center.x = self.preview.center.x
        self.takeButton.frame.origin.y = self.preview.frame.maxY + 10
        self.view.addSubview(self.takeButton)
    }

    @objc private func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
//
//    func saveImage(image: UIImage) -> URL? {
//        let fileManager = FileManager.default
//        var newAssetURL: URL? = nil
//
//        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        let filePath = "\(rootPath)/image.jpg"
//
//        let imageData = UIImageJPEGRepresentation(image, 1.0)
//
//        if fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil) {
//            print("Created file")
//        }
//
//        if (fileManager.fileExists(atPath: filePath)){
//            newAssetURL = URL(fileURLWithPath: filePath)
//        }
//
//        return newAssetURL
//    }
//
//    func saveVideo(fileUrl: URL) -> URL? {
//        let fileManager = FileManager.default
//        var newAssetURL: URL? = nil
//
//        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        let filePath = "\(rootPath)/video.mp4"
//
//        let data = try! Data(contentsOf: fileUrl)
//
//        if fileManager.createFile(atPath: filePath, contents: data, attributes: nil) {
//            print("Created file")
//        }
//
//        if (fileManager.fileExists(atPath: filePath)){
//            newAssetURL = URL(fileURLWithPath: filePath)
//        }
//
//        return newAssetURL
//    }

    @objc func take() {
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

    func segueCropView(image: UIImage) {
        self.presenter.stop()
        let vc = StoryboardBuilder<CropViewController>.generate()
        vc.capturedImage = image
        vc.output = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {

        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let image = UIImage(data: photoData!)!
            self.segueCropView(image: image)
        }
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            self.segueCropView(image: pickedImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.presenter.isEditmode = true
        picker.dismiss(animated: true, completion: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}

extension CameraViewController: CropViewControllerOutput {
    func didCropImage(image: UIImage) {
        self.presenter.saveImage(image: image)
    }
}

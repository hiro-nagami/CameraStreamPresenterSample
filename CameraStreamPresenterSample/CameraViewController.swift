//
//  CameraViewController.swift
//  CameraStreamPresenterSample
//
//  Created by Nagamine Hiromasa on 2017/11/13.
//  Copyright © 2017 Nagamine Hiromasa. All rights reserved.
//

import Foundation
import TOCropViewController
import UIKit
import AVKit
import MobileCoreServices
import Photos

class CameraViewController: UIViewController {
    var presenter: CameraStreamPresenterProtocol
    init(presenter: CameraStreamPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.presenter.isEditmode == false {
            self.openCamera()
        }
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let picker = UIImagePickerController()
            picker.modalPresentationStyle = .fullScreen
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeMovie] as [String]
            picker.delegate = self
            picker.modalTransitionStyle = .crossDissolve
            
            self.present(picker, animated: true, completion: nil)
        }
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

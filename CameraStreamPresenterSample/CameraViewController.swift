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
            picker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.delegate = self
            picker.modalTransitionStyle = .crossDissolve
            
            self.present(picker, animated: true, completion: nil)
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
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.presenter.isEditmode = true
        picker.dismiss(animated: true, completion: {
            self.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
}

extension CameraViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropToRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: {
            self.navigationController?.dismiss(animated: true, completion: nil)
            self.presenter.delegate?.didTakeImage(image: cropViewController.image)
        })
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        if cancelled {
            self.presenter.isEditmode = false
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }

}

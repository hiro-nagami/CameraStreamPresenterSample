//
//  ViewController.swift
//  CameraStreamPresenterSample
//
//  Created by Nagamine Hiromasa on 2017/11/13.
//  Copyright © 2017 Nagamine Hiromasa. All rights reserved.
//

import UIKit
import TOCropViewController

class ViewController: UIViewController {
    @IBOutlet weak var camerabutton: UIButton!
    var presenter = CameraStreamPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.camerabutton.addTarget(self, action: #selector(tappedCameraButton), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tappedCameraButton() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let picker = UIImagePickerController()
            picker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.delegate = self
            
            self.present(picker, animated: true, completion: nil)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let presenter = CameraStreamPresenter()
            presenter.image = pickedImage
            picker.dismiss(animated: true, completion: nil)
            
            let vc = TOCropViewController(croppingStyle: .default, image: presenter.image!)
            vc.aspectRatioLockEnabled = true
            vc.resetAspectRatioEnabled = false
            vc.aspectRatioPickerButtonHidden = true
            vc.setAspectRatioPresent(.preset4x3, animated: true)
            self.present(vc, animated: true, completion: nil)
        }
    }
}


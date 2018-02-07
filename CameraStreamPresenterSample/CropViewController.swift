//
//  CropViewController.swift
//  CameraStreamPresenterSample
//
//  Created by Nagamine Hiromasa on 2018/02/07.
//  Copyright © 2018 Nagamine Hiromasa. All rights reserved.
//

import Foundation
import UIKit
import SwiftCamScanner
import StoryboardBuilder_iOS

protocol CropViewControllerOutput: class {
    func didCropImage(image: UIImage)
}

class CropViewController: UIViewController, StoryboardBuilderProtocol {
    static var storyboardName: String = "Main"
    static var storyboardID: String = "CropViewController"

    @IBOutlet weak var cropView: CropView!
    weak var output: CropViewControllerOutput?

    var capturedImage: UIImage?

    lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onDoneTap))
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem = self.closeButton
        self.view.backgroundColor = .black
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        if let image = capturedImage {
            cropView.setUpImage(image: image)
        }
    }

    @objc func onDoneTap() {
        if capturedImage == nil {
            self.dismiss(animated: true, completion: nil)
            return
        }

        cropView.cropAndTransform(completionHandler: {(croppedImage) -> Void in
            self.output?.didCropImage(image: croppedImage)
            self.dismiss(animated: true, completion: nil)
        })
    }
}

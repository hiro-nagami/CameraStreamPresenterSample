//
//  ViewController.swift
//  CameraStreamPresenterSample
//
//  Created by Nagamine Hiromasa on 2017/11/13.
//  Copyright © 2017 Nagamine Hiromasa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var camerabutton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.camerabutton.addTarget(self, action: #selector(tappedCameraButton), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tappedCameraButton() {
        let cameraPresenter = CameraStreamPresenter()
        cameraPresenter.delegate = self
        let cameraVC = CameraViewController(presenter: cameraPresenter)
        let navCon = UINavigationController(rootViewController: cameraVC)
        self.present(navCon, animated: true, completion: nil)
    }
}

extension ViewController: CameraStreamPresenterDelegate {
    func didTakeImage(image: UIImage) {
        self.imageView.image = image
    }
}


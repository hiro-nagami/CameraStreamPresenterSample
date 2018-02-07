//
//  ViewController.swift
//  CameraStreamPresenterSample
//
//  Created by Nagamine Hiromasa on 2017/11/13.
//  Copyright © 2017 Nagamine Hiromasa. All rights reserved.
//

import UIKit
import AVKit
import Photos

class ViewController: UIViewController {
    @IBOutlet weak var camerabutton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    lazy var playerViewController: AVPlayerViewController = {
        let playerVC = AVPlayerViewController()
        playerVC.view.frame = self.imageView.bounds
        playerVC.delegate = self
//        self.imageView.addSubview(playerVC.view)
        return playerVC
    }()
    
    var cameraPresenter: CameraStreamPresenterProtocol = CameraStreamPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.camerabutton.addTarget(self, action: #selector(tappedCameraButton), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playerViewController.player?.play()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tappedCameraButton() {
        let cameraViewWireframe = CameraViewWireframe()
        cameraViewWireframe.presentCamera(from: self)
        cameraViewWireframe.output = self
        cameraViewWireframe.imageSize = self.imageView.frame.size
    }
    
    func updateView() {
        self.imageView.image = UIImage()
    }
}

extension ViewController: CameraStreamPresenterDelegate {
    func didFinishCamera() {
        if let imageURL = self.cameraPresenter.imageURL,
            let data = try? Data(contentsOf: imageURL) {
            self.imageView.image = UIImage(data: data)
        } else if let movieURL = self.cameraPresenter.movieURL {
            self.playerViewController.player = AVPlayer(url: movieURL)
        }
    }
}

extension ViewController: CameraViewWireframeOutput {
    func saveImage(image: UIImage) {
        self.imageView.image = image
    }
}

extension ViewController: AVPlayerViewControllerDelegate {
    func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        self.playerViewController.player?.play()
    }
}


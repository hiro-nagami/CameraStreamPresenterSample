//
//  CameraViewWireframe.swift
//  CameraStreamPresenterSample
//
//  Created by Nagamine Hiromasa on 2018/02/06.
//  Copyright © 2018 Nagamine Hiromasa. All rights reserved.
//

import Foundation
import UIKit

protocol CameraViewWireframeInput {
    func saveImage(image: UIImage)
}

protocol CameraViewWireframeOutput {
    func saveImage(image: UIImage)
}

class CameraViewWireframe: CameraViewWireframeInput {
    private lazy var viewController: CameraViewController = {
        let presenter = CameraStreamPresenter()
        presenter.wireframe = self
        return CameraViewController(presenter: presenter)
    }()

    var imageSize: CGSize?
    var output: CameraViewWireframeOutput?

    func saveImage(image: UIImage) {
        var outputImage = image

        if let size = self.imageSize {
            UIGraphicsBeginImageContext(size)
            image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            outputImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }

        self.output?.saveImage(image: outputImage)
    }

    func presentCamera(from: UIViewController) {
        let navigationController = UINavigationController(rootViewController: self.viewController)
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        from.present(navigationController, animated: true, completion: nil)
    }

    func presentLibrary(from: UIViewController) {
        let navigationController = UINavigationController(rootViewController: self.viewController)
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        from.present(navigationController, animated: true, completion: nil)
    }

    func push(from: UINavigationController) {
        from.pushViewController(self.viewController, animated: true)
    }
}

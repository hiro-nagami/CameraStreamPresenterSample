//
//  CameraStreamPresenter.swift
//  CameraStreamPresenterSample
//
//  Created by Nagamine Hiromasa on 2017/11/13.
//  Copyright © 2017 Nagamine Hiromasa. All rights reserved.
//

import Foundation
import UIKit

protocol CameraStreamPresenterDelegate {
    func didTakeImage(image: UIImage)
}

protocol CameraStreamPresenterProtocol {
    var delegate: CameraStreamPresenterDelegate? { set get }
    var isEditmode: Bool { get set }
}

class CameraStreamPresenter: CameraStreamPresenterProtocol {
    var delegate: CameraStreamPresenterDelegate?
    var isEditmode: Bool = false
}

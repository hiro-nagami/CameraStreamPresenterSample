//
//  CameraStreamPresenter.swift
//  CameraStreamPresenterSample
//
//  Created by Nagamine Hiromasa on 2017/11/13.
//  Copyright © 2017 Nagamine Hiromasa. All rights reserved.
//

import Foundation
import UIKit

protocol CameraStreamPresenterProtocol {
    var image: UIImage? { get set }
}


class CameraStreamPresenter: CameraStreamPresenterProtocol {
    var image: UIImage?
}

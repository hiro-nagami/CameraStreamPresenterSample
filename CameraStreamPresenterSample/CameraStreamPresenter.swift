//
//  CameraStreamPresenter.swift
//  CameraStreamPresenterSample
//
//  Created by Nagamine Hiromasa on 2017/11/13.
//  Copyright © 2017 Nagamine Hiromasa. All rights reserved.
//

import Foundation
import UIKit
import AVKit

protocol CameraStreamPresenterDelegate {
    func didFinishCamera()
}

protocol CameraStreamPresenterProtocol {
    var delegate: CameraStreamPresenterDelegate? { set get }
    var isEditmode: Bool { get set }
    var imageURL: URL? { get set }
    var movieURL: URL? { get set }
}

class CameraStreamPresenter: CameraStreamPresenterProtocol {
    var delegate: CameraStreamPresenterDelegate?
    var isEditmode: Bool = false
    var imageURL: URL?
    var movieURL: URL?
}

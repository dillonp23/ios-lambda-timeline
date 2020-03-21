//
//  CameraView.swift
//  LambdaTimeline
//
//  Created by Dillon P on 3/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraView: UIView {

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPlayerLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get { return videoPlayerLayer.session }
        set { videoPlayerLayer.session = newValue }
    }

}

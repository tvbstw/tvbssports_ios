//
//  PlayerViewControllerExtension.swift
//  videoCollection
//
//  Created by Woody on 2022/6/23.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit

extension VideoIDPlayerManager {
    static let PlayerViewTag: Int = 9999
    static let VideoIDPlayerFullScreenDidClose: String = "VideoIDPlayerFullScreenDidClose"
}

extension Notification.Name {
    static let VideoIDPlayerFullScreenDidClose: Notification.Name = .init(rawValue: VideoIDPlayerManager.VideoIDPlayerFullScreenDidClose)
}

extension UIViewController {
    // AVFullScreenViewController
    @objc dynamic func _tracked_viewWillDisappear(_ animated: Bool) {
        // run time 時是原生 viewWillDisappear
        _tracked_viewWillDisappear(animated)
        if "AVFullScreenViewController" == String(cString: class_getName(Self.self)) {
            NotificationCenter.default.post(name: .VideoIDPlayerFullScreenDidClose, object: nil)
        }
    }
    
    static func swizzleViewWillDesappear_for_detectFullScreenIsClose() {
        let originalSelector = #selector(UIViewController.viewWillDisappear(_:))
        let swizzledSelector = #selector(UIViewController._tracked_viewWillDisappear(_:))
        guard let originalMethod = class_getInstanceMethod(self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}


extension UIView {
    func removeVideoIDPlayer() {
        viewWithTag(VideoIDPlayerManager.PlayerViewTag)?.removeFromSuperview()
    }
}

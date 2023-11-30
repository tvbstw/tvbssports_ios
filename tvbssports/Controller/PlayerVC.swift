//
//  PlayerVC.swift
//  videoCollection
//
//  Created by leon on 2020/12/30.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import CocoaLumberjack

class PlayerVC: BaseVC {
    weak var avPlayer:VideoIDPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func readyToPlay(_ videoID: String, _ view: UIView) {
        VideoIDPlayerManager.shard.installOutLinePlayer(view, videoID: videoID, completion: { [weak self] player in
            self?.avPlayer = player
        })
    }
    
    func closePlayerVC() {
        if let topViewController = UIApplication.topViewController() {
            let className = NSStringFromClass(type(of: topViewController))
            if className == "AVPlayerViewController" {
                topViewController.dismiss(animated: true) {
                    self.removePlayer()
                }
            }
        }
    }
    
    func removePlayer() {
        avPlayer?.pauseVideo()
    }
}

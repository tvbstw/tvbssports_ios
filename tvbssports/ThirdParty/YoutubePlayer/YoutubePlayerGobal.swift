//
//  YoutubePlayerGobal.swift
//  healthmvp
//
//  Created by Woody on 2022/6/7.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit
import SnapKit
import CocoaLumberjack


typealias VideoIDPlayer = YoutubePlayer

class VideoIDPlayerManager: NSObject {
    private override init() {
        player = VideoIDPlayer()
        player.tag = VideoIDPlayerManager.PlayerViewTag
        super.init()
        player.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(removePlayerFromSuperView), name: .VideoIDPlayerFullScreenDidClose, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    static let shard: VideoIDPlayerManager = VideoIDPlayerManager()
    let player: VideoIDPlayer
    var currentVideoID: String?
}

extension VideoIDPlayerManager: YoutubeVideoPlayer{
    
    typealias Parameters = VideoIDPlayer.Parameters
    
    func loadWithVideoId(_ videoId: String, parameters: [Parameters]) {
        currentVideoID = videoId
        player.loadWithVideoId(videoId, parameters: parameters)
    }
    
    
    func loadVideo(byId: String, startSeconds: Float) {
        currentVideoID = byId
        player.loadVideo(byId: byId, startSeconds: startSeconds)
    }
    
    func playVideo() {
        player.playVideo()
    }
    
    func pauseVideo() {
        player.pauseVideo()
    }
    
    func reconnect() {
        player.reconnect()
    }
    
    @objc func removePlayerFromSuperView() {
        player.removeFromSuperview()
    }
}

extension VideoIDPlayerManager {

    func installInlinePlayer(_ view: UIView, videoID: String, completion: @escaping (VideoIDPlayer)-> Void) {
        self.player.pauseVideo()
        self.player.removeFromSuperview()
        view.addSubview(player)
        player.snp.makeConstraints({ (make) in
            make.edges.equalTo(view)
        })
        
        
        let parameters: [Parameters] = [
            Parameters.fullScreen(true),
            Parameters.controls(true),
            Parameters.modestbranding(false),
            Parameters.autoPlay(true),
            Parameters.playsinline(true)
        ]
        self.loadWithVideoId(videoID, parameters: parameters)
        completion(player)
    }
    
    func installOutLinePlayer(_ view: UIView, videoID: String, completion: @escaping (VideoIDPlayer)-> Void) {
        self.player.pauseVideo()
        self.player.removeFromSuperview()
        view.addSubview(player)
        player.snp.makeConstraints({ (make) in
            make.edges.equalTo(view)
        })
        
        let parameters: [Parameters] = [
            Parameters.fullScreen(true),
            Parameters.controls(true),
            Parameters.modestbranding(false),
            Parameters.autoPlay(true),
            Parameters.playsinline(false)
        ]
        self.currentVideoID = videoID
        self.loadWithVideoId(videoID, parameters: parameters)
        completion(player)
    }
}

extension VideoIDPlayerManager: YoutubePlayerDelegate {
    
    func playerViewDidBecomeReady(_ playerView: VideoIDPlayer) {
        self.player.playVideo()
    }
    
    func playerView(_ playerView: VideoIDPlayer, receivedError error: YoutubePlayerError) {
        DDLogError("VideoId: \(self.currentVideoID ?? "Null") receivedError: \(error)")
        guard let topVC = UIApplication.topViewController(),
              let videoID = self.currentVideoID else { return }
        let alertView = UIAlertController(title: "提醒", message: VIDEO_WARM, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: { (act) in
            if let url = URL(string: "\(YOUTUBE_URL)\(videoID)") {
                Util.shared.openSafari(url, topVC)
            }
        })
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        topVC.present(alertView, animated: true, completion: nil)
    }
}


//
//  YoutubePlayerComponent.swift
//  healthmvp
//
//  Created by Woody on 2022/6/7.
//  Copyright © 2022 Eddie. All rights reserved.


protocol YoutubeVideoPlayer {
    associatedtype Parameters
    func loadWithVideoId(_ videoId: String, parameters: [Parameters])
    func loadVideo(byId: String, startSeconds: Float)
    func playVideo()
    func pauseVideo()
    func reconnect()
}


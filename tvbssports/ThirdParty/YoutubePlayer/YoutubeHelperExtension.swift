//
//  YoutubeHelperExtension.swift
//  healthmvp
//
//  Created by Woody on 2022/6/7.
//  Copyright © 2022 Eddie. All rights reserved.
//

import CocoaLumberjack

typealias YoutubePlayer = YTPlayerView
typealias YoutubePlayerDelegate = YTPlayerViewDelegate
typealias  YoutubePlayerError = YTPlayerError

extension YTPlayerView: YoutubeVideoPlayer {
    
    enum Parameters {
        case autoPlay(Bool)
        case controls(Bool)
        case fullScreen(Bool)
        case modestbranding(Bool)
        case playsinline(Bool)
        case disablekb(Bool)
        
        var key: String {
            switch self {
            case .autoPlay:
                return "autoplay"
            case .controls:
                return "controls"
            case .fullScreen:
                return "fs"
            case .modestbranding:
                return "modestbranding"
            case .playsinline:
                return "playsinline"
            case .disablekb:
                return "disablekb"
            }
        }
        
        var value: Any {
            switch self {
            case .autoPlay(let bool):
                return bool.intValue
            case .controls(let bool):
                return bool.intValue
            case .fullScreen(let bool):
                return bool.intValue
            case .modestbranding(let bool):
                return bool.intValue
            case .playsinline(let bool):
                return bool.intValue
            case .disablekb(let bool):
                return bool.intValue
            }
        }
    }
    
    func loadWithVideoId(_ videoId: String, parameters: [Parameters]) {
        let vas = Dictionary(uniqueKeysWithValues: parameters.map { ($0.key, $0.value) })
        load(withVideoId: videoId, playerVars: vas)
    }
    
    func reconnect() {
        playerState { [weak self] state,_  in
            guard state != .ended,
                  state == .paused else { return }
            self?.playVideo()
        }
    }
}


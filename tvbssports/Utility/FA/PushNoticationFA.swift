//
//  PushNoticationFA.swift
//  videoCollection
//
//  Created by Woody on 2022/4/13.
//  Copyright © 2022 Eddie. All rights reserved.
//

import Foundation


extension Util {
    
    enum PushNotifacationType: String {
        case daily   = "每日"
        case article = "文章"
        case video   = "影片"
        case picture = "圖輯"
    }
    
    func pushNoticationIntoContent(title: String, type: PushNotifacationType) {
        let event = "detail_push"
        let action = "detail_push_content"
        let label = "\(title)_\(type.rawValue)_推播"
        setAnalyticsLogEnvent(event: event, action: action, label: label)
    }
    
    func pushVideoCollect(_ id: String) {
        let event = "click_collect"
        let action = "video_push_page_video_collect"
        let label = "\(id)_影片_收藏_影片內頁"
        setAnalyticsLogEnvent(event: event, action: action, label: label)
    }
    
    func pushVideoPlay(_ id: String) {
        let event = "click_play"
        let action = "video_push_page_video"
        let label = "\(id)_影片_影片內頁"
        setAnalyticsLogEnvent(event: event, action: action, label: label)
    }
    
    func pushShowScreen() {
        let event = "show_screen"
        let action = "Video Push Page"
        let label = "開啟_影片內頁"
        setAnalyticsLogEnvent(event: event, action: action, label: label)
    }
}

//
//  Enum.swift
//  videoCollection
//
//  Created by leon on 2020/12/23.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit

enum ReachabilityState: String {
    case cellular   = "Reachable via Cellular"
    case wifi       = "Reachable via WiFi"
    case unknow     = "Not reachable"
}

enum ErrorType: String {
    case empty          = "empty"
    case error          = "error"
    case unreachable    = "unreachable"
    case network        = "network"
    case service        = "service"
    case statusCode     = "statusCode"
    case `default`      = "default"
}

enum CellLayout: String {
    case video          = "video"
    case apiStatus      = "status"
    case unreachable    = "unreachable"
    case empty          = "empty"
    case noMoreData     = "noMoreData"
    case artcleList     = "artcleList"
    case rotate         = "rotate"
    case content        = "content"
    case extraHeader    = "extraHeader"
    case headline       = "headline"
    case category       = "category"
    case news           = "news"
    case live           = "live"
    case picture        = "picture"
    
    case prologueTitle  = "prologueTitle"
    case predictRotate  = "predictRotate"
    case remainTitle    = "remainTitle"
    case hotNewsRotate  = "hotNewsRotate"
    case listMore       = "listMore"
    case myRecord       = "myRecord"
    case bigCardAD      = "bigCardAD"
    case listCardAD     = "listCardAD"
    case bannerAD       = "bannerAD"
    
    case `default`      = "default"
}

enum FaEvent: String {
    case show_screen    = "show_screen"
    case click_video    = "click_video"
    case click_cancel   = "click_cancel"
    case click_collect  = "click_collect"
    case click_article  = "click_article"
    case click_play  = "click_play"
    case search         = "search"
}

enum ContentType: String {
    case keyViewP = "keyViewP"
    case keyViewV = "keyViewV"
    case title = "title"
    case editor = "editor"
    case date = "date"
    case text = "text"
    case image = "image"
    case alt = "alt"
    case article = "article"
    case `default` = "default"
}

//1.文章 2.影片 3.系統通知 4.活動公告 5.搖一搖 6.會員專屬 7.我的通知 8.分類頁跳轉 9.每日5則 10.圖輯
enum PushType: String {
    case article    = "1"
    case video      = "2"
    case system     = "3"
    case activity   = "4"
    case shake      = "5"
    case member     = "6"
    case mynote     = "7"
    case category   = "8"
    case dailyfive  = "9"
    case picture    = "10"
    case `default`  = ""
}


//1.webview 2.原生 0.原生
enum PushContentType: String {
    case webview    = "1"
    case origin     = "2"
    case origin1    = "0"
    case `default`  = ""
}

enum VCBehavior: String {
    case refresh   = "refresh"
    case loadMore  = "loadMore"
}

enum webSchemeType: String {
    case https          = "https"
    case http           = "http"
    case telprompt      = "telprompt"
    case sms            = "sms"
    case mailto         = "mailto"
    case line           = "line"
    case fbMessenger    = "fb-messenger"
    
    func addSlash() -> String {
        return "\(self)://"
    }
}

enum SocialType: String {
    case AppFacebook    = "facebook"
    case AppYoutube     = "youtube"
    case AppLine        = "line"
    case AppMessenger   = "messenger"
}

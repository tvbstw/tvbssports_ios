//
//  Global.swift
//  youtubeCollection
//
//  Created by leon on 2020/12/16.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit

var DOCUMENT_PATH: String {
    get {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return ""
        }
        return url.path
    }
}

var CACHES_PATH: String {
    get {
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return ""
        }
        return url.path
    }
}

var CURRENT_BUILD: String {
    get {
        if let info = Bundle.main.infoDictionary {
            if let str = info["CFBundleVersion"] as? String {
                return str
            }
        }
        return ""
    }
}
var CURRENT_VERSION: String {
    get {
        if let info = Bundle.main.infoDictionary {
            if let str = info["CFBundleShortVersionString"] as? String {
                return str
            }
        }
        return ""
    }
}
var APP_DISPLAY_NAME: String {
    get {
        if let info = Bundle.main.infoDictionary {
            if let str = info["CFBundleDisplayName"] as? String {
                return str
            }
        }
        return ""
    }
}

let DEVICE_VERSION  = UIDevice.current.systemVersion
let USER_DEFAULT = UserDefaults.standard

let US  = Util.shared
let DBS = DataBase.shared
let SM = SharedMemory.shared
let NOTIFICATION_CENTER = NotificationCenter.default

let BG_COLOR                  = UIColor.RGB(248, 248, 248)
let TABBAR_DEFAULT_COLOR      = UIColor.RGB(158, 158, 158)
let TABBAR_SELECTED_COLOR     = UIColor.RGB(223, 7, 18)
let MENU_DEFAULT_COLOR        = UIColor.RGB(99, 99, 99)
let MENU_SELECTED_COLOR       = UIColor.RGB(223, 7, 18)
//元件高度
//let TVBSPLUS_STATUS_HEIGHT = Float(UIApplication.shared.statusBarFrame.size.height)
//let TVBSPLUS_SCREEN_WIDTH  = Float(UIScreen.main.bounds.size.width)
//let TVBSPLUS_SCREEN_HEIGHT = Float(UIScreen.main.bounds.size.height)
let STATUS_HEIGHT = Float(UIApplication.shared.statusBarFrame.size.height)
let SCREEN_WIDTH  = Float(UIScreen.main.bounds.size.width)
let SCREEN_HEIGHT = Float(UIScreen.main.bounds.size.height)
let NOMOREDATA_HEIGHT = Float(40.0)
let TABBAR_HEIGHT = Float(49.0)

//title
let NEWS_TITLE    = "TVBS新聞"
let PLAYER_TITLE  = "食尚玩家"
let WOMAN_TITLE   = "女人我最大"
let HEALTH_TITLE  = "健康"

//常數
let W_ERROR:String = "error"
let W_EMPTY:String = "empty"
let W_UNREACHABLE:String = "unreachable"

let LOADING_IMGS_DURATION = 1.0
let IMAGE_FADE_SEC:TimeInterval = 0.2

let LOAD_MORE = "載入更多..."
let RELEASE_TO_LOAD = "放開後載入..."
let LOADING = "載入中..."
let VIDEO_WARM = "很抱歉，影片無法在此播放\n將前往Youtube觀看"
let YOUTUBE_URL = "https://www.youtube.com/watch?v="

let EMPTY_MESSAGE = "抱歉 頁面迷路了，快把他找回來吧！"
let EMPTY_RELOAD_BTN = "重整一下"
let ERROR_MESSAGE = "抱歉 頁面迷路了，快把他找回來吧！"
let UNREACHABLE_MESSAGE = "OMG 網路罷工了！\n確認網路連線是否正常"
let UNREACHABLE_RELOAD_BTN = "再試一次"
let ERROR_RELOAD_BTN = "重整一下"
let FORCE_UPDATE_WARM = "國際+有新版本嘍！\n效能優化，體驗更順暢。"
let UPDATE_BTN = "立即更新"
let DEVICE_TOKEN = "deviceToken"
let PUSH_MESSAGE = "pushMessage"
let IS_OPEN_HEADLINE = "isOpenHeadLine"
let HEADLINE_END_TIME = "headlineEndTime"
let RUN_PUSH_OR_HEADLINE = "runPushOrHeadline"

//api
#if DEVELOPMENT
let ROOT_DOMAIN = "https://plus-pre.tvbs.com.tw/"
let LEVEL = "api/"
let API_DOMAIN = "\(ROOT_DOMAIN)\(LEVEL)"
let APPLE_STORE_URL = "itms-beta://beta.itunes.apple.com/v1/app/1547570016"
#else
let ROOT_DOMAIN = "https://plus.tvbs.com.tw/"
let LEVEL = "api/"
let API_DOMAIN = "\(ROOT_DOMAIN)\(LEVEL)"
let APPLE_STORE_URL = "https://itunes.apple.com/tw/app/tvbsplus/id1548254760?l=zh&ls=1&mt=8"
#endif

let MENU_API    = "\(API_DOMAIN)menu?v=2"
//let MENU_API    = "http://leonrule.dsmynas.com:8080/tvbs_plus/menu.php"
let VERSION_API = "\(API_DOMAIN)version/i"
let SEARCH_API  = "\(API_DOMAIN)search"
let INITIALSNS_API  = "\(API_DOMAIN)initialsns"
let GLOBALNEWS_API  = "\(ROOT_DOMAIN)globalnews"
let VIDEO_INDEX_API = "\(API_DOMAIN)index"
let HEADLINENEWS_API  = "\(API_DOMAIN)dailytop"
let MARQUEE_API = "\(API_DOMAIN)flash_news"
let PICTURELIST_API  = "\(ROOT_DOMAIN)api/article_picture_list"
let PICTURECONTENT_API  = "\(ROOT_DOMAIN)api/article_picture"


//Navigation bar的字型與大小
let NAVIGATION_ITEM_ATTRS = [NSAttributedString.Key.foregroundColor:MENU_SELECTED_COLOR,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 19.0, weight: .medium)]

var VIDEO_ENABLED = true
let MAINSB = UIStoryboard.init(name: "Main", bundle: nil)
//let FONT_SIZE = [["title":14.0,"date":10.0],["title":18.0,"date":14.0],["title":22.0,"date":18.0],["title":26.0,"date":22.0]]
let FONT_SIZE = [["listTitle":14.0,"contentTitle":18.0,"contentEditor":10.0,"contentText":12.0],
                 ["listTitle":18.0,"contentTitle":22.0,"contentEditor":14.0,"contentText":16.0],
                 ["listTitle":22.0,"contentTitle":26.0,"contentEditor":18.0,"contentText":20.0],
                 ["listTitle":26.0,"contentTitle":30.0,"contentEditor":22.0,"contentText":24.0]]
//let FONT_SIZE = [["listTitle":14.0,"listDate":10.0,"contentTitle":18.0,"contentEditor":10.0,"contentText":12.0],
//                 ["listTitle":18.0,"listDate":14.0,"contentTitle":22.0,"contentEditor":14.0,"contentText":16.0],
//                 ["listTitle":22.0,"listDate":18.0,"contentTitle":26.0,"contentEditor":18.0,"contentText":20.0],
//                 ["listTitle":26.0,"listDate":22.0,"contentTitle":30.0,"contentEditor":22.0,"contentText":24.0]]
var SETTING_COLOR = UIColor.RGB(242.0, 242.0, 242.0)
var SETTING_LABEL_COLOR = UIColor.RGB(158.0, 158.0, 158.0)
let FONTSIZE_LABELS = ["小字","標準","大字","特大"]

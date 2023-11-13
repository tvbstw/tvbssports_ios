//
//  SocialKit.swift
//  videoCollection
//
//  Created by tvbs on 2022/3/25.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit
import CocoaLumberjack

class SocialKit: NSObject {
    
    fileprivate static let tFacebookName  = "fb"
    fileprivate static let tYoutubeName   = "youtube"
    fileprivate static let tLineName      = "line"
    fileprivate static let tMessengerName = "fb-messenger"
    
    //womanqueenwomanqueen
    fileprivate static let tFacebookID   = "111515882197852"
    fileprivate static let tYoutubeID    = "UC00wMIWR48SYidE6jmpL7Qg"
    fileprivate static let tLineID       = "@supertaste"
    
    fileprivate static let tItunesFacebookID  = "id284882215"
    fileprivate static let tItunesYoutubeID   = "id544007664"
    fileprivate static let tItunesLineID      = "id443904275"
    fileprivate static let tItunesMessengerID = "id454638411"

    class func isInstalled(_ social:SocialType) -> Bool {
        switch social {
        case .AppFacebook:
            let str = "\(tFacebookName)://"
            return self.canAppUrl(str)
        case .AppYoutube:
            let str = "\(tYoutubeName)://"
            return self.canAppUrl(str)
        case .AppLine:
            let str = "\(tLineName)://"
            return self.canAppUrl(str)
        case .AppMessenger:
            let str = "\(tMessengerName)://"
            return self.canAppUrl(str)
        }
    }
    
    class func addFriend(_ social:SocialType) {
        switch social {
        case .AppFacebook:
            let str = "fb://profile/\(tFacebookID)"
            self.openAppUrl(str)
            break
        case .AppYoutube:
            //let str = "youtube://user/\(tYoutubeID)"
            let str = "https://www.youtube.com/channel/\(tYoutubeID)"
            self.openAppUrl(str)
            break
        case .AppLine:
            let str = "line://ti/p/\(tLineID)"
            self.openAppUrl(str)
            break
        case .AppMessenger:
            break
            
        }
    }
    
    class func openInWeb(_ social:SocialType) {
        switch social {
        case .AppFacebook:
            self.openAppUrl("https://www.facebook.com/\(tFacebookID)")
            break
        case .AppYoutube:
            self.openAppUrl("https://www.youtube.com/channel/\(tYoutubeID)")
            break
        case .AppLine:
            break
        case .AppMessenger:
            break
        }
    }
    
    class func openInAppStore(_ social:SocialType) {
        switch social {
        case .AppFacebook:
            self.openAppUrl(self.itunesUrl(tFacebookName, tItunesFacebookID))
            break
        case .AppYoutube:
            self.openAppUrl(self.itunesUrl(tYoutubeName, tItunesYoutubeID))
            break
        case .AppLine:
            self.openAppUrl(self.itunesUrl(tLineName, tItunesLineID) )
            break
        case .AppMessenger:
            self.openAppUrl(self.itunesUrl(tMessengerName, tItunesMessengerID))
            break
        }
    }

    class func canAppUrl(_ urlStr:String) -> Bool {
        if let url = URL(string: urlStr) {
            let flag = UIApplication.shared.canOpenURL(url)
            return flag
        } else {
            return false
        }
    }
    
    class func openAppUrl(_ urlStr:String) {
        if let url = URL(string: urlStr) {
            UIApplication.shared.openURL(url)
        }
    }
    
    class func itunesUrl(_ name:String, _ identifier:String) -> String {
        return "https://itunes.apple.com/tw/app/\(name)/\(identifier)?mt=8"
    }

}

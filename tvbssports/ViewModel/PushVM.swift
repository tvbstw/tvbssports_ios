//
//  PushVM.swift
//  videoCollection
//
//  Created by Eddie on 2021/12/5.
//  Copyright © 2021 Eddie. All rights reserved.
//

import UIKit
import CocoaLumberjack
import SwiftDate

class PushVM {
    static let shared = PushVM()
    var isFromPush = false   //判斷是否是從推播點進來
    
    func savePushMessage(_ message: Data) {
        guard let jsonString = String(data: message, encoding: String.Encoding.utf8) else { return }
        guard let push = Push(JSONString: jsonString) else { return }
        let title    = US.checkNil(push.title)
        let ID       = US.checkNil(push.articleID)
        let pushType = US.checkNil(push.pushType)
        
        let pType = PushType(rawValue: pushType) ?? .default
        switch pType {
        case .dailyfive:
            US.pushNoticationIntoContent(title: title, type: .daily)
        case .article:
            US.pushNoticationIntoContent(title: title, type: .article)
        case .video:
            US.pushNoticationIntoContent(title: title, type: .video)
        case .picture:
            US.pushNoticationIntoContent(title: title, type: .picture)
        default:
            break
        }
        
        DDLogInfo(jsonString)
        USER_DEFAULT.set(jsonString, forKey: PUSH_MESSAGE)
        USER_DEFAULT.synchronize()
        NOTIFICATION_CENTER.post(name: NSNotification.Name(RUN_PUSH_OR_HEADLINE), object: nil)
    }
    
    func addNotifications() {
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name(RUN_PUSH_OR_HEADLINE), object: nil, queue: nil, using: self.runPushOrHeadline)
    }
    
    func removeNotifications() {
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name(RUN_PUSH_OR_HEADLINE), object: nil)
    }
    
    func runPushOrHeadline(_ notification: Notification?) {
        DDLogInfo("isFromPush:\(isFromPush)")
        if isFromPush {
            guard USER_DEFAULT.object(forKey: PUSH_MESSAGE) != nil else { return DDLogError("PUSH_MESSAGE is nil.")}
            guard let jsonString = USER_DEFAULT.object(forKey: PUSH_MESSAGE) as? String else {
                removePushMessage()
                return DDLogError("PUSH_MESSAGE is not string.")
            }
            
            guard let push = Push(JSONString: jsonString) else {
                removePushMessage()
                return DDLogError("PUSH_MESSAGE is not string.")
            }
            
            let pType = PushType(rawValue: Util.shared.checkNil(push.pushType)) ?? .default
                        
            switch pType {
            case .dailyfive:
                //從推播進來而且是每日5則時都要打開國際頭條
                showHeadlineNewsView()
            case .article:
                // APP- 775 [國際+][iOS]文章推播機制
                pushArticleViewController(push)
            case .video:
                pushVideoContentViewController(push)
                // APP- 906 [國際+][iOS]影片推播FA
            case .picture:
                // APP-1264 圖輯推播
                pushPictureContentViewController(push)
            default:
                print("default", push)
            }
            removePushMessage()
            return
        }
        
        if !isFromPush {
            /*
            let dateFormat = "yyyy-MM-dd HH:mm:ss"
            let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaTaipei, locale: Locales.chineseTaiwan)
            let lStartTimeDisplay = hlStartTime.convertTo(region: region).toString(.custom(dateFormat))
            let lEndTimeDisplay = hlEndTime.convertTo(region: region).toString(.custom(dateFormat))
            let lNowTimeDisplay = nowTime.convertTo(region: region).toString(.custom(dateFormat))
            DDLogInfo("👏startTime:\(lStartTimeDisplay) nowTime:\(lNowTimeDisplay) endTime:\(lEndTimeDisplay)")
            */
            let hlStartTime = DateInRegion(year: Date().year, month: Date().month, day: Date().day, hour: 3, minute: 50, second: 00).date
            let hlEndTime = DateInRegion(year: Date().year, month: Date().month, day: Date().day, hour: 15, minute: 59, second: 59).date
            let nowTime = Date.nowTime()
            
            DDLogInfo("👏startTime:\(hlStartTime) nowTime:\(nowTime) endTime:\(hlEndTime) flag:\(USER_DEFAULT.bool(forKey: IS_OPEN_HEADLINE))")
            
            //11:50~23:59:59 進入開啟國際頭條判斷
            if nowTime.isInRange(date: hlStartTime, and: hlEndTime) && !USER_DEFAULT.bool(forKey: IS_OPEN_HEADLINE) {
                DDLogInfo("Nowtime in Region.")
                //開啟國際頭條
                showHeadlineNewsView()
                
                //記錄當下endTime給IS_OPEN_HEADLINE判斷用
                USER_DEFAULT.set(hlEndTime, forKey: HEADLINE_END_TIME)
                USER_DEFAULT.set(true, forKey: IS_OPEN_HEADLINE)
                USER_DEFAULT.synchronize()
            }
            return
        }
    }
    
    /**
     從applicationDidBecomeActive進來時判斷IS_OPEN_HEADLINE是否需要重置，
     IS_OPEN_HEADLINE重置為false時在規定時間內國際頭條會顯示。
     */
    func checkIsOpenHeadline() {
        guard let udEndTime =  USER_DEFAULT.object(forKey: HEADLINE_END_TIME) as? Date else {
            return DDLogError("udEndTime is nil")
        }
        let nowTime = Date.nowTime()
        DDLogInfo("👏nowTime:\(nowTime) endTime:\(udEndTime) flag:\(USER_DEFAULT.bool(forKey: IS_OPEN_HEADLINE))")
        if nowTime > udEndTime {
            DDLogInfo("Reset IS_OPEN_HEADLINE")
            USER_DEFAULT.set(false, forKey: IS_OPEN_HEADLINE)
            USER_DEFAULT.synchronize()
        }
    }
    
    func showHeadlineNewsView() {
        guard SM.headlineNewsVC == nil else {
            DDLogInfo("headlineNewsVC exist.")
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { t in
            DDLogInfo("showHeadlineNewsView")
            let viewModel = HeadViewNewsViewModel()
            let topViewController = UIApplication.topViewController()
            viewModel.bindHeadViewNewsViewModelToController = { [weak topViewController] in
                let vc = HeadlineNewsVC(nibName: "HeadlineNewsVC", bundle: nil)
                SM.headlineNewsVC = vc
                SM.headlineNewsVC?.headlineNewsList = viewModel.HeadlineNewsList
                // APP- 839 點推播開啟［每日必看頭條］後，點影片播放，旋轉沒有切換成全畫面
                topViewController?.addChildViewControllAndFillOut(vc)
            }
        }
    }
    
    private func removePushMessage() {
        USER_DEFAULT.removeObject(forKey: PUSH_MESSAGE)
        USER_DEFAULT.synchronize()
        isFromPush = false
    }
}

extension PushVM {
    
    // MARK: APP- 775 [國際+][iOS]文章推播機制
    private func pushArticleViewController(_ push: Push) {
        guard let apiUrl = push.apiUrl,
              let categoryName = push.categoryName else { return }
        let tabVC = UIApplication.shared.tabViewController
        tabVC?.selectPage(.article)
        let naiVC = tabVC?.getNavigationController(.article)
        let vc = ContentVC(apiUrl, categoryName)
        naiVC?.pushViewController(vc, animated: true)
    }
    
    // MARK: APP-904 [國際+][iOS]影片推播機制與 UI實作
    private func pushVideoContentViewController(_ push: Push) {
        guard let apiUrl = push.apiUrl else { return }
        let tabVC = UIApplication.shared.tabViewController
        tabVC?.selectPage(.article)
        let naiVC = tabVC?.getNavigationController(.article)
        let vc = VideoContentVC(apiUrl)
        naiVC?.pushViewController(vc, animated: true)
    }
    
    // MARK: APP-1264 圖輯推播
    private func pushPictureContentViewController(_ push: Push) {
        guard let articleID = push.articleID, let ID = Int(articleID) else { return }
        guard let picture = PictureList(JSON: ["id":ID]) else { return }
        
        let tabVC = UIApplication.shared.tabViewController
        tabVC?.selectPage(.picture)
        guard let naiVC = tabVC?.getNavigationController(.picture) else { return }
        guard let pictureContentVC = MAINSB.instantiateViewController(withIdentifier: "pictureContentVC") as? PictureContentVC else {
            DDLogError("pictureContentVC is nil.")
            return
        }
        pictureContentVC.hidesBottomBarWhenPushed = true
        pictureContentVC.picture = picture
        naiVC.pushViewController(pictureContentVC, animated: true)
    }
}

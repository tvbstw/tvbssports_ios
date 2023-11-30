//
//  AppDelegate.swift
//  videoCollection
//
//  Created by leon on 2020/12/23.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import AVKit
import CocoaLumberjack
import ComScore
import FBSDKCoreKit
import Firebase
import FirebaseCrashlytics
import Flurry_iOS_SDK
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deviceToken = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AppLog.config()
        
        //Firebase Analytics
        var infoFileName = ""
        #if DEVELOPMENT
            infoFileName = "GoogleService-Info-dev"
        #else
            infoFileName = "GoogleService-Info"
        #endif
        DDLogInfo("\(infoFileName)")
        let filePath = Bundle.main.path(forResource: infoFileName, ofType: "plist")
        guard let fileopts = FirebaseOptions(contentsOfFile: filePath!) else {
            assert(false, "Couldn't load config file")
            return true
        }
        FirebaseApp.configure(options: fileopts)
        
        //Crashlytics
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        
        //Flurry
        var apiKey = ""
        #if DEVELOPMENT
            apiKey = "9NFDJD2RZCXQJ4MQ7M3M"
        #else
            apiKey = "PWYYWYMTH56Z52DVKP4R"
        #endif
        let sb = FlurrySessionBuilder()
            .build(logLevel: FlurryLogLevel.none)
            .build(crashReportingEnabled: true)
            .build(appVersion: CURRENT_VERSION)
            .build(sessionContinueSeconds: 10)
            //.build(iapReportingEnabled: true)
        Flurry.startSession(apiKey: apiKey, sessionBuilder: sb)
        
        //FB Analytics
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Comscore
        let publisherConfiguration = SCORPublisherConfiguration { (builder) in
            builder?.publisherId = "18400300"
        }
        SCORAnalytics.configuration().addClient(with: publisherConfiguration)
        SCORAnalytics.start()
        
        //Create SQLite DB
        DBS.createTable()
        DDLogInfo("DB_PATH:\(DOCUMENT_PATH)")
        
        
        //一天跳一次需要更新的提示
        if USER_DEFAULT.object(forKey: "update_date") == nil {
            USER_DEFAULT.set("", forKey: "update_date")
            USER_DEFAULT.synchronize()
        }
        
        if USER_DEFAULT.object(forKey: "fontSize") == nil {
           USER_DEFAULT.set(1, forKey: "fontSize")
           USER_DEFAULT.synchronize()
       }
        
        //靜音時可背景播放
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            DDLogInfo("AVAudioSession Category Playback OK")
        } catch {
            DDLogInfo("AVAudioSession error:\(error.localizedDescription)")
        }
        
        //Register Notification
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound], completionHandler: { (granted, error) in
            if granted {
                center.getNotificationSettings(completionHandler: { (UNNotificationSettings) in
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    DDLogInfo("register notification success")
                })
            } else {
                DDLogError("register notification fail")
            }
        })
        application.applicationIconBadgeNumber = 0
        
        
        //deviceToken初始化
        if USER_DEFAULT.object(forKey: DEVICE_TOKEN) == nil {
            USER_DEFAULT.set("", forKey: DEVICE_TOKEN)
            USER_DEFAULT.synchronize()
        } else {
            if let tmpToken = USER_DEFAULT.object(forKey: DEVICE_TOKEN) as? String {
                self.deviceToken = tmpToken
            }
        }
        
        //iOS11 搜尋頁導頁時會露出UIWindow的顏色故調整
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.windows.first {
                window.backgroundColor = UIColor.backgroundColor
            }
        }
        
        UIViewController.swizzleViewWillDesappear_for_detectFullScreenIsClose()
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        //token有改變時送到server端
        guard let tmpDeviceToken = USER_DEFAULT.object(forKey: DEVICE_TOKEN) as? String else { return }
        if tmpDeviceToken == "" {
            USER_DEFAULT.set(token, forKey: DEVICE_TOKEN)
            USER_DEFAULT.synchronize()
            self.deviceToken = token
            self.updateDeviceToken(self.deviceToken)
        } else {
            if tmpDeviceToken != token {
                USER_DEFAULT.set(token, forKey: DEVICE_TOKEN)
                USER_DEFAULT.synchronize()
                self.deviceToken = token
                self.updateDeviceToken(self.deviceToken)
                /* 20211130 Eddie These are code for members.
                if GlobalVars.mid != "" {
                    self.updateDeviceToken(self.deviceToken,GlobalVars.mid,"add")
                } else {
                    self.updateDeviceToken(self.deviceToken)
                }
                */
            } else {
                /* 20211130 Eddie These are code for members.
                if let deviceMid = USER_DEFAULT.string(forKey: "deviceMid") {
                    if deviceMid != "" && deviceMid != GlobalVars.mid {
                        self.updateDeviceToken(self.deviceToken,GlobalVars.mid,"add")
                    }
                }
                */
                self.deviceToken = tmpDeviceToken
            }
        }
        DDLogInfo("deviceToken:\(self.deviceToken)")
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
        guard let _ = self.window?.rootViewController  else {
            return
        }
        NOTIFICATION_CENTER.post(name: NSNotification.Name("WillEnterForeground"),object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { t in
            DDLogInfo("isFromPush:\(PushVM.shared.isFromPush)")
            PushVM.shared.checkIsOpenHeadline()
            NOTIFICATION_CENTER.post(name: NSNotification.Name(RUN_PUSH_OR_HEADLINE), object: nil)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func updateDeviceToken(_ token: String) {
        let params = ["platform":"i","token":token]
        PushM.shared.initialSNS(paramters: params) { (r) in
            if let errorMsg = r.errorMsg {
                DDLogError(errorMsg)
            }
            if let deviceID = r.deviceID {
                //取得API回傳裝置識別碼
                USER_DEFAULT.set(deviceID, forKey: "deviceID")
                USER_DEFAULT.synchronize()
            }
        }
    }
    
    /* 20211130 Eddie These are code for members.
    func updateDeviceToken(_ token: String, _ mid:String, _ type:String) {
        let params = ["platform":"i","token":token,"mid":mid,"type":type]
        PushM.shared.initialSNS(paramters: params) { (r) in
            if let errorMsg = r.errorMsg {
                DDLogError(errorMsg)
            }
            if let deviceID = r.deviceID {
                //取得API回傳裝置識別碼
                USER_DEFAULT.set(deviceID, forKey: "deviceID")
                USER_DEFAULT.synchronize()
            }
        }
    }
    */
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        //FB Analytics
        ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(
            app,
            open: url ,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //iOS 10 以上 處理前台收到通知的代理方法
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    //iOS 10 以上 處理後台點擊通知的代理方法
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let aps = response.notification.request.content.userInfo["aps"] as? [String:Any] {
            NotificationCenterChecker.log(aps: aps, at: "message")
            NotificationCenterChecker.checkType(aps: aps, at: "message")
            if let message = aps["message"] {
                do {
                    PushVM.shared.isFromPush = true
                    DDLogInfo("isFromPush:\(PushVM.shared.isFromPush)")
                    let jsonData = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
                    PushVM.shared.savePushMessage(jsonData)
                } catch {
                    DDLogError("JSONSerialization error:\(error.localizedDescription)")
                }
            }
        }
        completionHandler()
    }
}

class NotificationCenterChecker {}
extension NotificationCenterChecker {

    private struct NotifactionType: Codable {
        var push_type: String
        var article_id: String
        var category_id: String
    }
    
    class func log(aps info: [String: Any], at key: String) {
#if DEBUG
        print("--[NotificationCenterChecker.Log]-----------------------")
        guard let values = info[key] else {
            print(key, ": is not found")
            print("--[End]-----------------------")
            return
        }
        print("[NotificationCenterChecker] ", key, ": ")
        let message = """
\(values)
"""
        print(message)
        print("--[End]-----------------------")
#endif
    }
    
    class func checkType(aps info: [String: Any], at key: String) {
#if DEBUG
        print("--[NotificationCenterChecker.CheckType]-----------------------")
        guard let values = info[key] else {
            print(key, ": is not found")
            print("--[End]-----------------------")
            return
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: values, options: .prettyPrinted)
            let object = try JSONDecoder().decode(Self.NotifactionType.self, from: jsonData)
            print("Object:", object)
        }
        catch {
            print("Error:", error)
        }
        print("--[Deocde]-----------------------")
#endif
    }

}



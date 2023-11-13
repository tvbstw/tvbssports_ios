//
//  LaunchVC.swift
//  youtubeCollection
//
//  Created by leon on 2020/12/16.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Reachability

class LaunchVC: UIViewController {
    var delayTime = 1.5
    var myTimer:Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //組成loading陣列
        SM.loadingImgArr = Util.shared.loadingImages()
        
        //收藏資料
        SM.favoriteArr = DBS.queryFavorite()
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            let sb = UIStoryboard.init(name: "Main", bundle: Bundle.main)
//            let mainTBC = sb.instantiateViewController(withIdentifier: "mainTBC")
//            appDelegate.window?.rootViewController = mainTBC
//        }
        
        self.getNetworkStatus { [weak self] in
            self?.getVersion()
        }
    }
    
    //MARK: 檢查網路是否正常
    func getNetworkStatus(completion: @escaping ()->Void) {
        let reachability = try! Reachability()
        reachability.whenReachable = { _ in
            guard reachability.connection != .unavailable else {
                return
            }
            if reachability.connection == .wifi {
                DDLogInfo("Reachable via WiFi")
            } else {
                DDLogInfo("Reachable via Cellular")
            }
            completion()
        }
        reachability.whenUnreachable = { _ in
            DDLogInfo("Not reachable")
            let alert = UIAlertController(title: "提醒", message: UNREACHABLE_MESSAGE, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "再試一次", style: .default, handler: { (action) in
                let dispatchTime = DispatchTime.now() + 3.0
                DispatchQueue.global().asyncAfter(deadline: dispatchTime, execute: {
                    DDLogInfo("network retry")
                    self.getNetworkStatus(completion: completion)
                })
            })
            alert.addAction(okAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            DDLogInfo("Unable to start notifier")
        }
        reachability.stopNotifier()
    }
    
    //MARK: 比對版號
    func getVersion(){
        VersionM.shared.getVersionInfo { (r) in

            if let apiLimitVersion = r.limitVersion {
                let limitVersion = apiLimitVersion.replacingOccurrences(of: ".", with: "")
                let locationVersion = CURRENT_VERSION.replacingOccurrences(of: ".", with: "")
                DDLogInfo("locationVersion:\(locationVersion) limitVersion:\(limitVersion)")
                if locationVersion < limitVersion {
                    let alert = UIAlertController(title: "提醒", message: FORCE_UPDATE_WARM, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: UPDATE_BTN, style: .default, handler: { (action) in
                        if let appURL = URL(string: APPLE_STORE_URL) {
                            if UIApplication.shared.canOpenURL(appURL){
                                UIApplication.shared.openURL(appURL)
                                self.getVersion()
                            }
                        }
                    })
                    alert.addAction(okAction)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    if let uwVersion = r.version, let uwReleaseNote = r.releaseNote, let uwUpdateDate = USER_DEFAULT.string(forKey: "update_date") {
                        let version = uwVersion.replacingOccurrences(of: ".", with: "")
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "YYYY/MM/dd"
                        let today = dateFormatter.string(from: Date())
                        //print("today:\(today)")
                        if locationVersion < version && uwUpdateDate != today {
                            USER_DEFAULT.set(today, forKey: "update_date")
                            USER_DEFAULT.synchronize()
                            let alert = UIAlertController(title: "提醒", message: uwReleaseNote, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: UPDATE_BTN, style: .default, handler: { (action) in
                                if let appURL = URL(string: APPLE_STORE_URL) {
                                    if UIApplication.shared.canOpenURL(appURL){
                                        UIApplication.shared.openURL(appURL)
                                        self.getVersion()
                                    }
                                }
                            })
                            let cancelBtn = UIAlertAction(title: "取消", style: .default) { (act) in
                                self.chectNetStatusAndGoMainTBC()
                            }
                            alert.addAction(cancelBtn)
                            alert.addAction(okAction)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else {
                            self.chectNetStatusAndGoMainTBC()
                        }
                    } else {
                        self.getVersion()
                    }
                }
            } else {
                self.chectNetStatusAndGoMainTBC()
            }
        }
    }
    
    func chectNetStatusAndGoMainTBC() {
        let completion: ()->() = { [weak self] in
            guard let self = self else { return }
            self.myTimer = Timer.scheduledTimer(timeInterval: self.delayTime, target: self, selector: #selector(self.goMainTBC), userInfo: nil, repeats: false)
        }
        getNetworkStatus(completion: completion)
    }
    
    @objc func goMainTBC(sender:Timer) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let sb = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let mainTBC = sb.instantiateViewController(withIdentifier: "mainTBC")
        appDelegate.window?.rootViewController = mainTBC
    }
}

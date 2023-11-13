//
//  MainTBC.swift
//  youtubeCollection
//
//  Created by leon on 2020/12/16.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import MessageUI

class MainTBC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        SM.tabbarController = self
        self.delegate = self
        self.setAppearence()
        addNotifications()
    }
    
    deinit {
        removeNotifications()
    }
    
    func setAppearence() {
        UITabBar.appearance().barTintColor = UIColor.backgroundColor
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.textColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.selectColor], for: .selected)
    }
    
    func addNotifications() {
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("settingBtnClick"), object: nil, queue: nil, using: self.settingBtnClick)
    }
    
    func removeNotifications(){
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("settingBtnClick"), object: nil)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let items = tabBar.items {
            if let index = items.firstIndex(of: item) {
                var faEvent = ""
                var faAction = ""
                var faLabel = ""
                switch index {
                    case 0:
                        faEvent  = "bottomtab_index"
                        faAction = "bottomtab_index"
                        faLabel = "開啟_首頁"
                        break
                    case 1:
                        faEvent  = "bottomtab_article"
                        faAction = "bottomtab_article"
                        faLabel = "開啟_文章"
                        break
                    case 2:
                        faEvent  = "bottomtab_img"
                        faAction = "bottomtab_img"
                        faLabel = "開啟_圖輯"
                    case 3:
                        faEvent  = "bottomtab_collect"
                        faAction = "bottomtab_collect"
                        faLabel = "開啟_收藏"
                    case 4:
                        faEvent  = "bottomtab_search"
                        faAction = "bottomtab_search"
                        faLabel = "開啟_搜尋"
                    default:
                        break
                }
                US.setAnalyticsLogEnvent(event: faEvent, action: faAction, label: faLabel)
            }
        }
    }
    
    func settingBtnClick(_ notification:Notification) {
        let settingVC = MAINSB.instantiateViewController(withIdentifier: "settingVC") as! SettingVC
        settingVC.hidesBottomBarWhenPushed = true
        if let topViewController = UIApplication.topViewController() {
            let event = "navigation_fontsize"
            let action = "navigation_fontsize"
            let label = "開啟_設定字級"
            //  如果是由tab present
            switch topViewController {
            case is VideoIndexVC:
                US.setAnalyticsLogEnvent(event: "\(event)", action: "\(action)_index", label: "\(label)_首頁")
            case is ListVC:
                US.setAnalyticsLogEnvent(event: "\(event)", action: "\(action)_cate", label: "\(label)_分類頁")
            case is ArticleListVC:
                US.setAnalyticsLogEnvent(event: "\(event)", action: "\(action)_article", label: "\(label)_文章頁")
            case is ContentVC:
                US.setAnalyticsLogEnvent(event: "\(event)", action: "\(action)_detailarticle", label: "\(label)_文章內頁")
            case is PictureContentVC:
                US.setAnalyticsLogEnvent(event: "\(event)", action: "\(action)_detailimg", label: "\(label)_圖輯內頁")
            default:
                print("")
            }
            if topViewController.presentingViewController != nil {
                UIApplication.topViewController()?.show(settingVC, sender: nil)
            } else {
                self.selectedViewController?.show(settingVC, sender: nil)
            }
        }
    }
}

extension MainTBC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let currentIndex = tabBarController.viewControllers?.firstIndex(of: viewController) {
            if tabBarController.selectedIndex == 0 && currentIndex == 0 {
                NOTIFICATION_CENTER.post(name: NSNotification.Name("scrollToTop"),object: nil)
            }
        }
        return true
    }
    
}

extension MainTBC {
    func sendLog() {
        if MFMailComposeViewController.canSendMail() {
            let mcVC = MFMailComposeViewController()
            mcVC.mailComposeDelegate = self
            mcVC.title = "寄送LOG"
            mcVC.setSubject("寄送LOG")
            mcVC.setToRecipients(["dev.eddie.wu@gmail.com"])
            //log folder
            let savePath = "\(CACHES_PATH)/logs.zip"
            let source   = "\(CACHES_PATH)/Logs"
            if US.createZip(savePath: savePath, source: source) {
                guard let logsData = NSData(contentsOfFile: savePath) else { return }
                mcVC.addAttachmentData(logsData as Data, mimeType: "application/zip", fileName: "\(CACHES_PATH)/logs.zip")
            }
            let defaultBody =  String(format: "<br/><br/><br/>Product：%@ (%@)<br/>Device：%@<br/>iOS：%@<br/>檢查碼：%@","", "", "", "", "")
            mcVC.setMessageBody(defaultBody, isHTML: true)
            self.present(mcVC, animated: true, completion: nil)
        }else{
            let message = "該設備尚未設定郵件帳號"
            let alertView = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
            alertView.addAction(cancelAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }
}

extension MainTBC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        var resultTitle :String = ""
        var resultMsg :String = ""
        switch result {
        case .cancelled:
            break
        case .saved:
            resultTitle = "郵件已保存"
            resultMsg   = "你的郵件已保存為草稿。"
            break
        case .sent:
            resultTitle = "郵件已寄出"
            resultMsg   = "你的郵件已成功送出。"
            break
        case .failed:
            resultTitle = "郵件發送失敗"
            resultMsg   = "抱歉，郵件發送失敗，請再試一次。"
            break
        default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
        if resultTitle != "" {
            let alertView = UIAlertController(title: resultTitle, message: resultMsg, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
            alertView.addAction(cancelAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }
}


extension MainTBC {
    
    enum SelectIndexType: Int {
        case main, article, picture, collect, search
    }
    
    func selectPage(_ type: SelectIndexType) {
        selectedIndex = type.rawValue
    }
    
    func getNavigationController(_ type: SelectIndexType)-> UINavigationController? {
        guard let vcs = viewControllers else { return nil }
        let index = type.rawValue
        return vcs.indices.contains(index) ? vcs[index] as? UINavigationController : nil
    }
}


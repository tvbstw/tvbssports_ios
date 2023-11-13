//
//  ListVC.swift
//  youtubeCollection
//
//  Created by leon on 2020/12/21.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CocoaLumberjack
import SwiftDate
import Firebase

class ListVC: ButtonBarPagerTabStripViewController {
    fileprivate var savedChildViewControllers = [UIViewController]()
    var moveIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        let btn = UIButton.customBtnForBarButtonItem("left", "", "icon_back")
        btn.addTarget(self, action: #selector(customBackItemClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
        self.settings.style.selectedBarBackgroundColor = UIColor.selectColor
        self.settings.style.buttonBarItemTitleColor = UIColor.textColor
        self.settings.style.selectedBarHeight = 3.8
        self.settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 19, weight: .regular)
        self.settings.style.buttonBarItemBackgroundColor = UIColor.backgroundColor
        
        buttonBarView.selectedBar.backgroundColor = UIColor.selectColor
        buttonBarView.backgroundColor = UIColor.backgroundColor
        changeCurrentIndexProgressive = {(oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.font = UIFont.systemFont(ofSize: 19, weight: .regular)
            newCell?.label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
            oldCell?.label.textColor = UIColor.textColor
            newCell?.label.textColor = UIColor.selectColor
        }
        
        addNotifications()
        
        sendTabFA()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    deinit {
        removeNotifications()
    }
    
    //Firebase Analytics 20220623
    func sendTabFA() {
//        didSelectItemAtClosure = { index in
//            for (menuIndex, menu) in SM.menuArr.enumerated() {
//                guard index == menuIndex else { continue }
//                guard let categoryName = menu.category_name, let name = menu.name else { continue }
//
//                let tabEvent = "tab"
//                let tabParams = ["action":"tab_\(categoryName)", "label":"開啟_\(name)"]
//                Analytics.logEvent(tabEvent, parameters: tabParams)
//                DDLogInfo("⛔️event: \(tabEvent), params: \(tabParams)")
//            }
//        }
    }
    
    
    func moveToSpecificPage () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.moveToViewController(at: self.moveIndex, animated: true)
        }
    }
    
    func addNotifications() {
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("scrollToTop"), object: nil, queue: nil, using: self.scrollToTop)
    }
    
    func removeNotifications() {
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("scrollToTop"), object: nil)
    }
    
    func scrollToTop(_ notification: Notification) {
        NOTIFICATION_CENTER.post(name: NSNotification.Name("needScrollToTop"),object: nil,userInfo:["controller":savedChildViewControllers[currentIndex]])
    }
    
    @objc func customBackItemClick() {
        guard !self.isModal else {
            self.dismiss(animated: false, completion: nil)
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
     
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var childViewControllers = [UIViewController]()

        for menu in SM.menuArr  {
            if let layout = menu.layout, let name = menu.name ,let category_name = menu.category_name {
                switch layout {

                case "1":
                    childViewControllers.append(VideoListVC(itemInfo: IndicatorInfo(title: "\(name)"), menu: menu ,category_name:category_name ))
//                case "2":
//                    childViewControllers.append(ArticleListVC(itemInfo: IndicatorInfo(title: "\(name)"), menu: menu))
                default:
                    break
                }

            }
        }
        savedChildViewControllers = childViewControllers
        return childViewControllers
    }
}

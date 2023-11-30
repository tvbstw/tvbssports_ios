//
//  SearchTabVC.swift
//  videoCollection
//
//  Created by darren on 2020/12/24.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SearchTabVC: ButtonBarPagerTabStripViewController {

    var searchStr:String?
    var preloadFlg = true
    var titleDict = [String:String]()
    var isReloadCell = false
    var childVCCount = 0
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.backgroundColor
        self.setNavigation()
        
        settings.style.buttonBarBackgroundColor = UIColor.backgroundColor
        settings.style.buttonBarItemBackgroundColor = UIColor.backgroundColor
        settings.style.selectedBarBackgroundColor = UIColor.selectColor
        settings.style.buttonBarItemTitleColor = UIColor.backgroundColor
    
        super.viewDidLoad()
        
        changeCurrentIndexProgressive = {(oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            if self.preloadFlg {
                oldCell?.label.textColor = UIColor.textColor
                newCell?.label.textColor = UIColor.selectColor
                oldCell?.label.font = UIFont.systemFont(ofSize: 19, weight: .regular)
                newCell?.label.font = UIFont.systemFont(ofSize: 19, weight: .regular)
            } else {
                oldCell?.label.textColor = UIColor.textColor
                newCell?.label.textColor = UIColor.selectColor
                oldCell?.label.font = UIFont.systemFont(ofSize: 19, weight: .regular)
                newCell?.label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.preloadFlg {
            for index in 0..<SM.menuArr.count {
                self.moveToViewController(at: index, animated: false)
            }
            preloadFlg = false
            self.moveToViewController(at: 0, animated: false)
        }
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
       
        var childViewControllers = [UIViewController]()
        for menu in SM.menuArr {
            if let title = menu.name, let menuID = menu.ID, let layout = menu.layout, let category = menu.category_name {
                if layout == "1" {
                    let listVC = SearchListVC()
                    //listVC.menuID = menuID
                    listVC.searchTitle = title
                    listVC.keyword = self.searchStr ?? ""
                    listVC.superParent = self
                    listVC.categoryName = category
                    childViewControllers.append(listVC)
                }
            }
        }
        self.childVCCount = childViewControllers.count
        
        return childViewControllers
        
//        let newsVC = SearchListVC()
//        newsVC.keyword = searchStr
//        newsVC.searchTitle = NEWS_TITLE
//        newsVC.superParent = self
//
//        let PlayerVC = SearchListVC()
//        PlayerVC.keyword = searchStr
//        PlayerVC.searchTitle = PLAYER_TITLE
//        PlayerVC.superParent = self
//
//        let WomanVC = SearchListVC()
//        WomanVC.keyword = searchStr
//        WomanVC.searchTitle = WOMAN_TITLE
//        WomanVC.superParent = self
//
//        let HealthVC = SearchListVC()
//        HealthVC.keyword = searchStr
//        HealthVC.searchTitle = HEALTH_TITLE
//        HealthVC.superParent = self
//
//        return [newsVC,PlayerVC,WomanVC,HealthVC]
    }

    func reloadButtonBarCellWidth() {
        //確定內容頁面title數量是否load完
        guard titleDict.count == self.childVCCount else {
            return
        }
    
        if !self.isReloadCell {
            self.preloadFlg = true
            self.isReloadCell = true
            self.reloadPagerTabStripView()
   
            for index in 0..<self.childVCCount {
                self.moveToViewController(at: index, animated: false)
            }
            preloadFlg = false
            self.moveToViewController(at: 0, animated: false)
        }
    }
    
    func setNavigation() {
        self.navigationItem.hidesBackButton = true
        let btn = UIButton.customBtnForBarButtonItem("left", self.searchStr ?? "", "icon_back")
        btn.addTarget(self, action: #selector(customBackItemClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    @objc func customBackItemClick() {
        self.navigationController?.popViewController(animated: true)
    }

}

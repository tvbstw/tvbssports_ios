//
//  FavoriteVC.swift
//  youtubeCollection
//
//  Created by Oscsr on 2020/12/21.
//  Copyright © 2020 Oscsr. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class FavoriteVC: ButtonBarPagerTabStripViewController {
    var preloadFlg = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "收藏"
        self.navigationController?.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor:UIColor.textColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 19.0, weight: .medium)]
        buttonBarView.selectedBar.backgroundColor = UIColor.selectColor
        buttonBarView.backgroundColor = UIColor.backgroundColor
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.settings.style.selectedBarBackgroundColor = UIColor.selectColor
        self.settings.style.buttonBarItemTitleColor = UIColor.textColor
        self.settings.style.selectedBarHeight = 3.8
        self.settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 19, weight: .regular)
        self.settings.style.buttonBarItemBackgroundColor = UIColor.backgroundColor
        
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
        containerView.isScrollEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.preloadFlg {
            preloadFlg = false
            self.moveToViewController(at: 0, animated: false)
        }
        
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var childViewControllers = [UIViewController]()
    
        let info = IndicatorInfo.init(title: "收藏 (0)")
        let favoriteListVC = FavoriteListVC(itemInfo: info, parent: self)
        childViewControllers.append(favoriteListVC)
        
        return childViewControllers
        
    }
    
    // MARK: Rotate
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get {
            return .portrait
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


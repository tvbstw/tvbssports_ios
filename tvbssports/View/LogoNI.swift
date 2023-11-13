//
//  LogoNI.swift
//  youtubeCollection
//
//  Created by leon on 2020/12/21.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit

class LogoNI: UINavigationItem {
    override func awakeFromNib() {
        self.titleView = UIView.navigtionItemTitleView()
        self.titleView?.contentMode = .scaleAspectFit
    }
}

class LogoNIAndRightButtion: UINavigationItem {
    override func awakeFromNib() {
        self.titleView = UIView.navigtionItemTitleView()
        self.titleView?.contentMode = .scaleAspectFit
        
        let settingBI = SettingBI()
        self.rightBarButtonItem = settingBI
    }
}

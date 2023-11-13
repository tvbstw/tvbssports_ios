//
//  SettingBI.swift
//  videoCollection
//
//  Created by leon on 2021/1/27.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit
import CocoaLumberjack

class SettingBI: UIBarButtonItem {
    
    override init() {
        super.init()
        if let image = UIImage(named: "icon_text_level") {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            button.setBackgroundImage(image, for: .normal)
            self.customView = button
            button.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func click(_ sender:UIBarButtonItem) {
        NOTIFICATION_CENTER.post(name: NSNotification.Name("settingBtnClick"), object: nil, userInfo: nil)
    }
}

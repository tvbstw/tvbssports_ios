//
//  MemberBarItem.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/23.
//  Copyright © 2023 Eddie. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MemberBarItem: UIBarButtonItem {
    
    override init() {
        super.init()
        if let image = UIImage(named: "MemberButton") {
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
        NOTIFICATION_CENTER.post(name: NSNotification.Name("memberBarItemClick"), object: nil, userInfo: nil)
    }
}

//
//  BaseVC.swift
//  videoCollection
//
//  Created by darren on 2021/12/29.
//  Copyright © 2021 Eddie. All rights reserved.
//

import UIKit
import MBProgressHUD

class BaseVC: UIViewController {
    
    var hud: MBProgressHUD?
    
    var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: MBProgressHUD
    func showHUD() {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func showHUDonKeyWindow() {
        self.hud = MBProgressHUD.showAdded(to: keyWindow ?? self.view , animated: true)
    }
    
    func hiddenHUD() {
        if let uwHud = self.hud {
            uwHud.hide(animated: true)
        }
    }
}

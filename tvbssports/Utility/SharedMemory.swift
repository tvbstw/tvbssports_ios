//
//  SharedMemory.swift
//  youtubeCollection
//
//  Created by leon on 2020/12/17.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit

class SharedMemory: NSObject {
    static let shared = SharedMemory()
    var loadingImgArr: [UIImage]!
    var menuArr = [Menu]()
    var favoriteArr = [String]()
    var headlineNewsVC: HeadlineNewsVC?
    var tabbarController: UITabBarController?
}


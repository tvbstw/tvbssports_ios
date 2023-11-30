//
//  OpenURLLayer.swift
//  videoCollection
//
//  Created by Woody on 2022/3/23.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit

protocol OpenBrowserUrlLayer {}
extension OpenBrowserUrlLayer {
    func openBrowser(_ urlString: String) {
        openBrowser(URL(string: urlString))
    }
    
    func openBrowser(_ url: URL?) {
        guard let url = url else { return }
        UIApplication.shared.open(url)
    }
}

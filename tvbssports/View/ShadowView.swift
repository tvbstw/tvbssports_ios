//
//  ShadowView.swift
//  supertastemvp
//
//  Created by darren on 2020/5/11.
//  Copyright © 2020 Eddie. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    var cornerRadius:CGFloat = 15
    override var bounds: CGRect {
        didSet {
           setupShadow()
        }
    }

    func setupShadow(shadowRadius:CGFloat = 4 , color:CGColor = UIColor.black.cgColor) {
         self.layer.shadowColor = color
         self.layer.shadowOffset = CGSize.zero
         self.layer.shouldRasterize = true
         self.layer.rasterizationScale = UIScreen.main.scale
         self.layer.shadowRadius = shadowRadius
         self.layer.shadowOpacity = 0.5
         self.layer.shadowPath = UIBezierPath(roundedRect:  bounds, cornerRadius: cornerRadius).cgPath
     }
}

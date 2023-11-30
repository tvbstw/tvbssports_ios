//
//  GradientView.swift
//  woman
//
//  Created by Eddie on 2018/4/17.
//  Copyright © 2018年 Eddie. All rights reserved.
//

import UIKit

class CycleTitleGradientView: UIView {

    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //let color:UIColor    = .black
        //let colors:[CGColor] = [color.withAlphaComponent(0.0).cgColor,
        //                        color.withAlphaComponent(0.5).cgColor,
        //                        color.withAlphaComponent(0.8).cgColor,
        //                        color.cgColor]
        let colors:[CGColor] = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(1.0).cgColor]
        let gradient = self.layer as! CAGradientLayer
        gradient.colors = colors
        gradient.contentsScale = UIScreen.main.scale
        //gradient.locations = [0.0, 0.2, 0.4, 0.6]
        gradient.locations = [0.0, 1]
        gradient.startPoint = CGPoint(x: 0.2, y: 0)
        gradient.endPoint = CGPoint(x: 0.2, y: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CategoryGradientView: UIView {
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let color:UIColor    = UIColor.black
        let colors:[CGColor] = [color.withAlphaComponent(0.0).cgColor,
                                color.withAlphaComponent(0.1).cgColor,
                                color.withAlphaComponent(0.2).cgColor,
                                color.withAlphaComponent(0.3).cgColor,
                                color.withAlphaComponent(0.4).cgColor,
                                color.withAlphaComponent(0.5).cgColor]
        let gradient = self.layer as! CAGradientLayer
        gradient.colors = colors
        gradient.contentsScale = UIScreen.main.scale
        //gradient.locations = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
        gradient.locations = [0.0, 0.2, 0.4, 0.6]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
    }
}


class PictureGradientView: UIView {
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let color:UIColor    = UIColor.black
//        let colors:[CGColor] = [color.withAlphaComponent(0.0).cgColor,
//                                color.withAlphaComponent(0.1).cgColor,
//                                color.withAlphaComponent(0.2).cgColor,
//                                color.withAlphaComponent(0.3).cgColor,
//                                color.withAlphaComponent(0.4).cgColor,
//                                color.withAlphaComponent(0.5).cgColor]
        let colors:[CGColor] = [color.withAlphaComponent(0.0).cgColor,
                                color.withAlphaComponent(0.1).cgColor,
                                color.withAlphaComponent(0.3).cgColor,
                                color.withAlphaComponent(0.6).cgColor,
                                color.withAlphaComponent(0.7).cgColor,
                                color.withAlphaComponent(0.8).cgColor]
        let gradient = self.layer as! CAGradientLayer
        gradient.colors = colors
        gradient.contentsScale = UIScreen.main.scale
        //gradient.locations = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
        gradient.locations = [0.0, 0.2, 0.4, 0.6]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
    }
}

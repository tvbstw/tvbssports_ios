//
//  BottomShareView.swift
//  videoCollection
//
//  Created by darrenChiang on 2022/7/6.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit

@objc protocol BottomShareViewProtocol: NSObjectProtocol {
    func shareBtnClick()
}

class BottomShareView: UIView {

    @IBOutlet
    weak var delegate:BottomShareViewProtocol?
    
    @IBOutlet var contentView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        guard let view = loadViewFromNib() else { return }
           view.frame = self.bounds
           self.addSubview(view)
    }

    override init(frame: CGRect) {
          super.init(frame: frame)
        guard let view = loadViewFromNib() else { return }
           view.frame = self.bounds
           self.addSubview(view)
      }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "BottomShareView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    
    @IBAction func buttonAction(_ sender: Any) {
        self.delegate?.shareBtnClick()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    
    
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "BottomShareView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}

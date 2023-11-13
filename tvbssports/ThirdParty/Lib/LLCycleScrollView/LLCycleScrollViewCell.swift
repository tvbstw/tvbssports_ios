//
//  LLCycleScrollViewCell.swift
//  LLCycleScrollView
//
//  Created by LvJianfeng on 2016/11/22.
//  Copyright © 2016年 LvJianfeng. All rights reserved.
//

import UIKit
// 20180417 修改套件 支援GIF Eddie
import Kingfisher
class LLCycleScrollViewCell: UICollectionViewCell {
    
    // 标题
    var title: String = "" {
        didSet {
            //titleLabel.text = "\(title)"
            
            // 20180417 修改套件 title支援行距調整。 Eddie
            let paragraphstyle = NSMutableParagraphStyle()
            paragraphstyle.alignment = .justified
            paragraphstyle.lineHeightMultiple = 1
            let attrs: [NSAttributedString.Key:Any] = [NSAttributedString.Key.font:self.titleFont,
                                                       NSAttributedString.Key.paragraphStyle: paragraphstyle]
            self.titleLabel.attributedText = NSAttributedString(string: self.title, attributes: attrs)
            
            if title.count > 0 {
                titleBackView.isHidden = false
                titleLabel.isHidden = false
            }else{
                titleBackView.isHidden = true
                titleLabel.isHidden = true
            }
        }
    }
    
    // 标题颜色
    var titleLabelTextColor: UIColor = UIColor.white {
        didSet {
            titleLabel.textColor = titleLabelTextColor
        }
    }
    
    // 标题字体
    var titleFont: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            titleLabel.font = titleFont
        }
    }
    
    // 文本行数
    var titleLines: NSInteger = 2 {
        didSet {
            titleLabel.numberOfLines = titleLines
        }
    }
    
    // 标题文本x轴间距
    var titleLabelLeading: CGFloat = 15 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    // 标题背景色
    var titleBackViewBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.3) {
        didSet {
            //titleBackView.backgroundColor = titleBackViewBackgroundColor
        }
    }
    
    var titleBackView: UIView!
    
    // 标题Label高度
    var titleLabelHeight: CGFloat! = 56 {
        didSet {
            layoutSubviews()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupLabelBackView()
        setupTitleLabel()
    }
    
    // 图片
    // 20180417 修改套件 支援GIF Eddie
    var imageView: AnimatedImageView!
    fileprivate var titleLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setup ImageView
    fileprivate func setupImageView() {
        //imageView = UIImageView.init()
        // 20180417 修改套件 支援GIF Eddie
        imageView = AnimatedImageView()
        // 默认模式
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.contentView.addSubview(imageView)
    }
    
    // Setup Label BackView
    fileprivate func setupLabelBackView() {
        // 20180731 修改套件 加大間距 Leon
        titleBackView = CycleTitleGradientView.init(frame: CGRect.init(x: 0, y: self.ll_h - titleLabelHeight * 1.2, width: self.ll_w, height: titleLabelHeight * 1.2))
        titleBackView.isHidden = true
        self.contentView.addSubview(titleBackView)
    }
    
    // Setup Title
    fileprivate func setupTitleLabel() {
        titleLabel = UILabel.init()
        titleLabel.isHidden = true
        titleLabel.textColor = titleLabelTextColor
        titleLabel.numberOfLines = titleLines
        titleLabel.font = titleFont
        titleLabel.backgroundColor = UIColor.clear
        titleBackView.addSubview(titleLabel)
    }
    
    // MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = self.bounds
        //titleBackView.frame = CGRect.init(x: 0, y: self.ll_h - titleLabelHeight, width: self.ll_w, height: titleLabelHeight)
        titleLabel.frame = CGRect.init(x: titleLabelLeading, y: 0, width: self.ll_w - titleLabelLeading - 5, height: titleLabelHeight)
    }
}

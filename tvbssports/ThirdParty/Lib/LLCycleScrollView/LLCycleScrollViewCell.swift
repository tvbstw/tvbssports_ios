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
                titleLabel.isHidden = false
            }else{
                titleLabel.isHidden = true
            }
        }
    }
    
    // 标题
    var date: String = "" {
        didSet {
            //titleLabel.text = "\(title)"
            
            // 20180417 修改套件 title支援行距調整。 Eddie
            let paragraphstyle = NSMutableParagraphStyle()
            paragraphstyle.alignment = .justified
            paragraphstyle.lineHeightMultiple = 1
            let attrs: [NSAttributedString.Key:Any] = [NSAttributedString.Key.font:self.titleFont,
                                                       NSAttributedString.Key.paragraphStyle: paragraphstyle]
            self.dateLabel.attributedText = NSAttributedString(string: self.date, attributes: attrs)
            
            if date.count > 0 {
                dateLabel.isHidden = false
            }else{
                dateLabel.isHidden = true
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
    var dateBackView: UIView!
    
    // 标题Label高度
    var titleLabelHeight: CGFloat! = 56 {
        didSet {
            layoutSubviews()
        }
    }
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupTitleLabel()
        setupDateLabel()
    }
    
    // 图片
    // 20180417 修改套件 支援GIF Eddie
    var imageView: AnimatedImageView!
    fileprivate var titleLabel: UILabel!
    // 日期標籤
    fileprivate var dateLabel: UILabel!
    
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
    
    // Setup Title
    fileprivate func setupTitleLabel() {
        titleLabel = UILabel.init()
        titleLabel.isHidden = true
        titleLabel.textColor = titleLabelTextColor
        titleLabel.numberOfLines = titleLines
        titleLabel.font = titleFont
        titleLabel.backgroundColor = UIColor.clear
        self.contentView.addSubview(titleLabel)
    }
    
    // 設定日期標籤
    fileprivate func setupDateLabel() {
        dateLabel = UILabel()
        dateLabel.isHidden = true
        dateLabel.textColor =  UIColor(red: 0.665, green: 0.685, blue: 0.7, alpha: 1) // 或是設定您想要的顏色
        dateLabel.font = UIFont.systemFont(ofSize: 12) // 或是設定您想要的字型和大小
        dateLabel.backgroundColor = UIColor.clear
        self.contentView.addSubview(dateLabel)
    }
    
    // MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect.init(x: 0, y: 0, width: self.ll_w, height: 180)
        titleLabel.frame = CGRect.init(x: 12 , y: 180 , width: self.ll_w - 24 , height: titleLabelHeight)
        dateLabel.frame = CGRect.init(x: 12 , y: 236 , width: self.ll_w - 24, height: 16)
    }
}

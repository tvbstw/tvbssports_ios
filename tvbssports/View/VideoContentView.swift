//
//  VideoContentView.swift
//  videoCollection
//
//  Created by Woody on 2022/4/12.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import KingfisherWebP


class VideoContentView: UIView {
    
    static let DefaultImage: String = "img_default_16_9"
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "img_default_16_9")
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        return iv
    }()
    
    let playButton: UIButton = {
        let btn = UIButton()
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setBackgroundImage(UIImage(named: "icon_videoe_paly"), for: .normal)
        btn.setBackgroundImage(UIImage(named: "icon_videoe_paly"), for: .normal)
        return btn
    }()
    
    let titleLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        lb.adjustsFontSizeToFitWidth = true
        lb.textAlignment = .left
        lb.font = .systemFont(ofSize: 18)
        lb.minimumScaleFactor = 16
        lb.textColor = .textColor
        return lb
    }()
    
    let timeLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.text = "影片時長 "
        lb.numberOfLines = 1
        lb.textColor = .videoTimeColor
        return lb
    }()
    
    let onairImgView: UIImageView = {
        let iv = UIImageView()
        iv.image = .onairImage
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let favoriteIcon: FavoriteIconView = FavoriteIconView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .clear
        addSubview(imageView)
        addSubview(playButton)
        addSubview(titleLabel)
        addSubview(timeLabel)
        addSubview(onairImgView)
        addSubview(favoriteIcon)
        
        imageView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 16 / 9).isActive = true
        
        playButton.snp.makeConstraints { make in
            make.width.equalTo(playButton.snp_height)
            make.width.equalTo(50)
            make.centerX.centerY.equalTo(imageView.snp_center)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp_bottom).offset(8)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.left.equalToSuperview().offset(10)
        }
        
        onairImgView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp_top)
            make.left.equalTo(timeLabel.snp_left)
            
        }
        
        favoriteIcon.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom)
            make.right.bottom.equalToSuperview()
            make.width.equalTo(50)
        }
        
        
        
    }
}

extension VideoContentView {
    
    func configureItem(_ itemContent: VideoItemContent) {
        adjustLableFont()
        
        imageView.kf.setImage(with: URL(string: itemContent.image ?? ""), placeholder: UIImage(named: Self.DefaultImage), options: [.transition(ImageTransition.fade(0.2)), .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)], progressBlock: nil, completionHandler: nil)
        
        timeLabel.isHidden = isHiddenTimeLabel(itemContent)
        
        favoriteIcon.isHidden = isHiddenFavoriteIcon(itemContent)
        
        onairImgView.isHidden = isHiddenOnairIcon(itemContent)
        
        let prefix = "影片時長"
        
        titleLabel.text = itemContent.title
        
        timeLabel.text = itemContent.videoTime == nil ? "" :  "\(prefix) \(itemContent.videoTime!)"
        
        adjustFavoriteIcon(itemContent.isKeeping)
    }
    
    func adjustLableFont() {
        titleLabel.font = UIFont.systemFont(ofSize: .ListTitleFontSize)
    }
    
    func adjustFavoriteIcon(_ isKeeping: Bool) {
        favoriteIcon.imageView.image = isKeeping ? .iconKeep : .iconNotKeep
    }
    
    private func isHiddenOnairIcon(_ itemContent: VideoItemContent)-> Bool {
        return itemContent.platlistID != "live" || (itemContent.videoTime != "0:00" && itemContent.videoTime != "00:00")
    }
    
    private func isHiddenTimeLabel(_ itemContent: VideoItemContent)-> Bool {
        return itemContent.platlistID == "live" || itemContent.videoTime == "0:00" || itemContent.videoTime == "00:00" || itemContent.videoTime == nil
    }
    
    private func isHiddenFavoriteIcon(_ itemContent: VideoItemContent)-> Bool {
        return itemContent.platlistID == "live"
    }
    
}

extension VideoContentView {
    class FavoriteIconView: UIView {
        let imageView: UIImageView = {
           let iv = UIImageView()
            iv.contentMode = .scaleAspectFit
            return iv
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-8)
                make.width.equalTo(17)
                make.height.equalTo(23)
                make.centerY.equalToSuperview()
            }
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}



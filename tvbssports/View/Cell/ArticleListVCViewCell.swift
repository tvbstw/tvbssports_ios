//
//  ArticleListVCViewCell.swift
//  videoCollection
//
//  Created by darrenChiang on 2021/7/1.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit
import Kingfisher
import KingfisherWebP
import CocoaLumberjack
import AudioToolbox

protocol ArticleListVCViewCellDelegate: NSObjectProtocol {
    func clickCollectSuccess(videoID:String , categoryName:String , name:String)
    func clickCollectCancel(videoID:String, categoryName:String , name:String)
}

class ArticleListVCViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    //影音按鈕、onAir圖示跟收藏按鈕 預設是隱藏
    @IBOutlet weak var favView: UIView!
    @IBOutlet weak var favIV: UIImageView!
    @IBOutlet var ImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet weak var onAirIV: UIImageView!
    
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var playicon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    open var data:ChosenList?
    
    weak var delegate:ArticleListVCViewCellDelegate?
    var fromVC:UIViewController?
    var atDict:Dictionary<String, String> = [:]
    var faDict:Dictionary<String, String> = [:]
    var isHiddenPlayicon = false
    var categoryName : String = ""
    var categoryChineseName : String = ""
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ImageView.removeVideoIDPlayer()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let collectionTapAction = UITapGestureRecognizer(target: self, action: #selector(self.favTap(_:)))
        self.favView.isUserInteractionEnabled = true
        self.favView.addGestureRecognizer(collectionTapAction)
        onAirIV.isHidden = true
    }
    @objc func favTap(_ sender:UITapGestureRecognizer) {
        guard let uwData = self.data else { return }
        if let vid = data?.videoItem?.videoID {
            if SM.favoriteArr.contains("\(vid)") {
                self.favIV.image = .iconNotKeep
                DBS.delFavorite(uwData)
                if let uwFromVC = self.fromVC{
                    US.addToast(uwFromVC.view, "取消收藏成功", .center)
                    self.delegate?.clickCollectCancel(videoID: vid ,categoryName:categoryName, name: categoryChineseName)
                }
            }else{
                self.favIV.image = .iconKeep
                DBS.addFavorite(uwData)
                if let uwFromVC = self.fromVC{
                    US.addToast(uwFromVC.view, "收藏成功", .center)
                    self.delegate?.clickCollectSuccess(videoID: vid ,categoryName:categoryName,name: categoryChineseName)
                }
            }
            NOTIFICATION_CENTER.post(name: NSNotification.Name("reloadKeepUI"),object: nil,userInfo:["fromVC":fromVC as Any])
            NOTIFICATION_CENTER.post(name: NSNotification.Name("reloadFavoriteList"),object: nil)
            AudioServicesPlaySystemSound(1520)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension ArticleListVCViewCell {
    func configureWithData(_ data: ArticleListContent?) {
        
        guard let data = data,
              let imageUrl = data.image,
              let uwTitle = data.title
        else { return }
      
        if let uwData = uwTitle.data(using: String.Encoding.utf8) {
            if let attributedString = try? NSAttributedString(data: uwData, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
                titleLabel.text = attributedString.string
            } else {
                titleLabel.text = data.title
            }
        } else {
            titleLabel.text = data.title
        }
        let fontSize = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["listTitle"]
        self.titleLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize ?? 14))
        self.dateLabel.text = data.publish
        Util.shared.setImage(ImageView, imageUrl)
        self.dateLabel.isHidden = false
        self.onAirIV.isHidden = true
        self.timeView.isHidden = true
        self.playicon.isHidden = true
        self.timeLabel.isHidden = true
        
        self.timeLabel.text = ""
        if let videoTime = data.videoTime {
            self.timeLabel.text = videoTime
        } else {}
        
        if let videoID = data.videoID {
            if videoID != "" {
                self.timeView.isHidden = false
                self.playicon.isHidden = false
                self.timeLabel.isHidden = false
            }
        }
        if self.isHiddenPlayicon {
            self.timeView.isHidden = true
            self.playicon.isHidden = true
            self.timeLabel.isHidden = true
        }
    }
}

extension ArticleListVCViewCell {
    func configureWithData(_ data: ChosenList?) {
        self.data = data
        guard let video = data?.videoItem,
              let imageUrl = video.image,
              let isLive = data?.isLive
        else { return }
        // APP-782 [iOS] 現正直播icon靠右 需調整UI
 
        self.categoryName = video.categoryName ?? ""
        self.categoryChineseName = video.name ?? ""
        self.timeView.isHidden = false
        self.playicon.isHidden = false
        self.timeLabel.isHidden = false
        
        self.favIV.isHidden = isLive
        self.favView.isHidden = isLive
        self.dateLabel.isHidden = isLive
        self.onAirIV.isHidden = !isLive
        
        let isInvalidVideoTime = !video.isValidVideoTime
        
        self.timeView.isHidden = isLive || self.isHiddenPlayicon || isInvalidVideoTime
        self.playicon.isHidden = isLive || self.isHiddenPlayicon || isInvalidVideoTime
        self.timeLabel.isHidden = isLive || self.isHiddenPlayicon || isInvalidVideoTime
        
        timeLabel.text = ""
        dateLabel.text = video.publish

        timeLabel.text = video.videoTime
        
        var titleFontSize = CGFloat(14.0)

        if let titleFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["listTitle"] {
            titleFontSize = CGFloat(titleFont)
        }
        titleLabel.font = UIFont.systemFont(ofSize: titleFontSize)

        
        self.ImageView.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage.defaultImage, options: [.transition(ImageTransition.fade(0.2)), .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)], progressBlock: nil, completionHandler: nil)

        if let vid = data?.videoItem?.videoID {
            if SM.favoriteArr.contains("\(vid)") {
                self.favIV.image = .iconKeep
            }else{
                self.favIV.image = .iconNotKeep
            }
        }
        
        
        guard let uwTitle = video.title else {
            return
        }
        
        if let uwData = uwTitle.data(using: String.Encoding.utf8) {
            if let attributedString = try? NSAttributedString(data: uwData, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
                titleLabel.text = attributedString.string
            } else {
                titleLabel.text = video.title
            }
        } else {
            titleLabel.text = video.title
        }
        
    }
}

extension ArticleListVCViewCell {
    func configureWithLiveData(_ data: VideoItemContent?) {
        //self.data = data
        guard let video    = data,
              let videoID  = video.videoID,
              let imageUrl = video.image
        else { return }
        
        let isLive = video.isLive
        
        self.categoryName = data?.categoryName ?? ""
        self.categoryChineseName = data?.name ?? ""
        self.timeView.isHidden = false
        self.playicon.isHidden = false
        self.timeLabel.isHidden = false
        
        self.favIV.isHidden = isLive
        self.favView.isHidden = isLive
        self.dateLabel.isHidden = isLive
        self.onAirIV.isHidden = !isLive
        
        
        let isInvalidVideoTime = !video.isValidVideoTime
        
        self.timeView.isHidden = isLive || self.isHiddenPlayicon || isInvalidVideoTime
        self.playicon.isHidden = isLive || self.isHiddenPlayicon || isInvalidVideoTime
        self.timeLabel.isHidden = isLive || self.isHiddenPlayicon || isInvalidVideoTime
        
        timeLabel.text = ""
        dateLabel.text = video.publish

        timeLabel.text = video.videoTime
        
        var titleFontSize = CGFloat(14.0)

        if let titleFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["listTitle"] {
            titleFontSize = CGFloat(titleFont)
        }
        titleLabel.font = UIFont.systemFont(ofSize: titleFontSize)

        
        self.ImageView.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage.defaultImage, options: [.transition(ImageTransition.fade(0.2)), .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)], progressBlock: nil, completionHandler: nil)

        
        if SM.favoriteArr.contains("\(videoID)") {
            self.favIV.image = .iconKeep
        }else{
            self.favIV.image = .iconNotKeep
        }
        
        guard let uwTitle = video.title else {
            return
        }
        
        if let uwData = uwTitle.data(using: String.Encoding.utf8) {
            if let attributedString = try? NSAttributedString(data: uwData, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
                titleLabel.text = attributedString.string
            } else {
                titleLabel.text = video.title
            }
        } else {
            titleLabel.text = video.title
        }
        
    }
}

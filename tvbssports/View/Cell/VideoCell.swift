//
//  VideoCell.swift
//
//
//  Created by tvbs on 2020/12/24.
//  Copyright © 2020 Chris. All rights reserved.
//

import UIKit
import Kingfisher
import KingfisherWebP
import CocoaLumberjack
import AudioToolbox

protocol VideoCellDelegate: NSObjectProtocol {
    func clickCollectSuccess(videoID:String)
    func clickCollectCancel(videoID:String)
}


class VideoCell: UITableViewCell {
    
    @IBOutlet var containView: UIView!
    @IBOutlet weak var mainIV: AnimatedImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var playIconIV: UIImageView!
    @IBOutlet weak var favView: UIView!
    @IBOutlet weak var favIV: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var onAirIV: UIImageView!
    
    open var data:ChosenList?
    
    weak var delegate:VideoCellDelegate?
    var fromVC:UIViewController?
    var atDict:Dictionary<String, String> = [:]
    var faDict:Dictionary<String, String> = [:]
    override func prepareForReuse() {
        super.prepareForReuse()
        mainIV.removeVideoIDPlayer()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.favView.isHidden = true
        let collectionTapAction = UITapGestureRecognizer(target: self, action: #selector(self.favTap(_:)))
        self.favView.isUserInteractionEnabled = true
        self.favView.addGestureRecognizer(collectionTapAction)
        
        containView.layer.cornerRadius = 0
        containView.layer.masksToBounds = false
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
                    self.delegate?.clickCollectCancel(videoID: vid)
                }
            }else{
                self.favIV.image = .iconKeep
                DBS.addFavorite(uwData)
                if let uwFromVC = self.fromVC{
                    US.addToast(uwFromVC.view, "收藏成功", .center)
                    self.delegate?.clickCollectSuccess(videoID: vid)
                    if let enName = data?.videoItem?.enName, let name = data?.videoItem?.name {
                        US.setAnalyticsLogEnvent(event: "click_collect", action: "index_video_collect", label: "\(vid)_影片_收藏_首頁")
                    }
                }
            }
            NOTIFICATION_CENTER.post(name: NSNotification.Name("reloadKeepUI"),object: nil,userInfo:["fromVC":fromVC as Any])
            NOTIFICATION_CENTER.post(name: NSNotification.Name("reloadFavoriteList"),object: nil)
            AudioServicesPlaySystemSound(1520)
        }
    }
    
    func configureWithData(_ data: VideoItemContent) {
        
        let tempData = ChosenList()
        tempData.videoItem = data
        
        let isValidVideoTime = data.isValidVideoTime
        
        let isLive = data.isLive
        
        self.data = tempData
        
        guard  let imageUrl = data.image else {
            return
        }
        
        self.favIV.isHidden = isLive
        self.favView.isHidden = isLive
        self.onAirIV.isHidden = !isLive
        self.dateLbl.isHidden = !isValidVideoTime
        
        dateLbl.text = ""
        if let videotime = data.videoTime {
            dateLbl.text = "影片時長:\(videotime)"
        }
        
        self.mainIV.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage.defaultImage, options: [.transition(ImageTransition.fade(0.2)), .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)], progressBlock: nil, completionHandler: nil)

        if let vid = data.videoID {
            if SM.favoriteArr.contains("\(vid)") {
                self.favIV.image = .iconKeep
            }else{
                self.favIV.image = .iconNotKeep
            }
        }
    }
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

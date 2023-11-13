//
//  HeadlineNewsSmallCell.swift
//  videoCollection
//
//  Created by darren on 2021/12/3.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit
import Kingfisher
import KingfisherWebP

class HeadlineNewsSmallCell: UITableViewCell, NewsImageCellProtocol {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var videoTimeLabel: UILabel!
    @IBOutlet var newsImageView: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var videoTimeView: UIView!
    @IBOutlet var bottomLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureWithData(data:HeadlineNews , showLine:Bool = false) {
    
        self.titleLabel.text = data.title
        self.videoTimeLabel.text = data.video_time
        self.timeLabel.text = data.publish
        self.bottomLineView.isHidden = showLine
        guard let imageurl = data.image else {
            return
        }
        self.newsImageView.kf.setImage(with: URL(string: imageurl), placeholder: UIImage(named:"img_default_16_9"), options: [.transition(ImageTransition.fade(0.2)), .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)], progressBlock: nil, completionHandler: nil)
        
        let videoTime = data.video_time
       // videoTimeView.isHidden = videoTime == "" ? true : false
        
        //video_id == nil 表示是文章不是影片
        guard let _ = data.video_id else {
            videoTimeView.isHidden = true
            return
        }
    }
    
}

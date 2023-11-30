//
//  HeadlineNewsBigCell.swift
//  videoCollection
//
//  Created by darren on 2021/12/3.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit
import Kingfisher
import KingfisherWebP

protocol NewsImageCellProtocol {
    var newsImageView: UIImageView! { get set }
}

class HeadlineNewsBigCell: UITableViewCell, NewsImageCellProtocol {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var videoTimeLabel: UILabel!
    @IBOutlet var newsImageView: UIImageView!
    @IBOutlet var triangleView: UIView!
    @IBOutlet var topNumberLabel: UILabel!
    @IBOutlet var playIcon: UIImageView!
    @IBOutlet var videoTimeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImageView.removeVideoIDPlayer()
    }
    func initView()  {
        // red triangeView
        let heightWidth = triangleView.frame.size.width
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x:heightWidth, y: 0))
        path.addLine(to: CGPoint(x:0, y:heightWidth))
        path.addLine(to: CGPoint(x:0, y:0))
        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = UIColor.red.cgColor
        triangleView.layer.insertSublayer(shape, at: 0)
        videoTimeView.backgroundColor = UIColor.RGBA(0, 0, 0, 0.4)
        videoTimeView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithData(data:HeadlineNews) {
        titleLabel.text = data.title
        let videoTime = data.video_time ?? ""
        videoTimeView.isHidden = videoTime == "" ? true : false
        videoTimeLabel.text = "影片時長 \(videoTime)"
        
        guard let imageurl = data.image else {
            return
        }
        self.newsImageView.kf.setImage(with: URL(string: imageurl), placeholder: UIImage(named:"img_default_5_6"), options: [.transition(ImageTransition.fade(0.2)), .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)], progressBlock: nil, completionHandler: nil)
        
        guard let _ = data.video_id else {
            videoTimeView.isHidden = true
            playIcon.isHidden = true
            return
        }
        
    }
    
    @IBAction func playBtnAction(_ sender: Any) {
        
    }
}





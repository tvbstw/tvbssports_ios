//
//  ColHeadLineCell.swift
//  videoCollection
//
//  Created by Eddie on 2021/12/10.
//  Copyright © 2021 Eddie. All rights reserved.
//

import UIKit

class ColHeadLineCell: UICollectionViewCell {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var mainIV: UIImageView!
    @IBOutlet weak var topIV: UIImageView!
    @IBOutlet weak var playIconIV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var videoTimeView: UIView!
    @IBOutlet weak var videoTimeLbl: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shadowView.backgroundColor = UIColor.RGBA(0, 0, 0, 0.4)
        videoTimeView.layer.cornerRadius = 5
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        mainIV.removeVideoIDPlayer()
    }
    
    func configureWithData(_ data: VideoIndexData) {
        topIV.isHidden = true
        titleLbl.text = data.title
        playIconIV.isHidden = data.videoID != "" ? false : true
        
        guard let videoTime = data.videoTime else {
            videoTimeView.isHidden = true
            return
        }
        
        guard videoTime != "" else {
            videoTimeView.isHidden = true
            return
        }
        
        videoTimeView.isHidden = false
        videoTimeLbl.text = "影片時長 \(videoTime)"
    }
}

//
//  PictureContentListCell.swift
//  videoCollection
//
//  Created by darrenChiang on 2022/6/24.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit
import Kingfisher
import KingfisherWebP

class PictureContentListCell: UITableViewCell {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var descriptionlabel: UILabel!
     
    @IBOutlet var imageViewHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureWithData(data:PictureImage?, imageSize:CGSize?) {
    
        descriptionlabel.text = data?.text ?? ""
        let timeFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["contentEditor"]
        descriptionlabel.font = UIFont.systemFont(ofSize: timeFont ?? 14)
        
        guard let imageUrl = URL(string: data?.image ?? "") else {
            return
        }
        
        //取原圖片size，沒取得預設320 * 320 正方形
        let size = imageSize
        let imageHeight = size?.height ?? 320
        let imageWidth = size?.width ?? 320
        
        //依照寬等比例縮放圖片
        let aspectRatio = imageHeight/imageWidth
        let containerWidth = UIScreen.main.bounds.width - 20
        let imageViewHeight = containerWidth * aspectRatio
        self.imageViewHeightConstraint.constant  = imageViewHeight
        
        self.pictureImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named:"img_default_16_9"), options: [.transition(ImageTransition.fade(0.2)), .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)], progressBlock: nil, completionHandler: nil)
    }
    
    
}



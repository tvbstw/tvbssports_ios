//
//  ImageUICollectionViewCell.swift
//  CHTWaterfallSwift
//
//  Created by Sophie Fader on 3/21/15.
//  Copyright (c) 2015 Sophie Fader. All rights reserved.
//

import UIKit
import Kingfisher
import KingfisherWebP

class ImageUICollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureWithData(data:PictureList? , index:IndexPath) {
        let image = index.row % 2 == 0 ? data?.cover_v : data?.cover_h
        guard let imageUrl = image , let name = data?.name else {
          return
        }
        
        self.titleLabel.text = name
        
        self.image.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named:"img_default_16_9"), options: [.transition(ImageTransition.fade(0.2)), .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)], progressBlock: nil, completionHandler: nil)
        
    }
    
}

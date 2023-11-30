//
//  ColPictureCell.swift
//  videoCollection
//
//  Created by Eddie on 2022/6/21.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit

class ColPictureCell: UICollectionViewCell {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var pictureIV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func configureWithData(_ data: PictureList) {
        titleLbl.text = data.name
    }
}

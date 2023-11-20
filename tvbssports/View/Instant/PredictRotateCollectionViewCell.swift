//
//  PredictRotateCollectionViewCell.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/15.
//  Copyright © 2023 Eddie. All rights reserved.
//

import UIKit

class PredictRotateCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var homeIV: UIImageView!
    @IBOutlet weak var awayIV: UIImageView!
    @IBOutlet weak var awayButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var dateTimeLable: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func configureWithData(_ data: PictureList) {
        //TODO
    }
}

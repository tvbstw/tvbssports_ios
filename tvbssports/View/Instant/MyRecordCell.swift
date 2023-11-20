//
//  MyRecordCell.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/20.
//  Copyright © 2023 Eddie. All rights reserved.
//

import UIKit

class MyRecordCell: UITableViewCell {

    @IBOutlet weak var rankingImage: UIImageView!
    
    @IBOutlet weak var rankingTitleLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var hitRateLabel: UILabel!
    @IBOutlet weak var liftingLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

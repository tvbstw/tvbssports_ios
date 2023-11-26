//
//  SportsArticleListCell.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/20.
//  Copyright © 2023 Eddie. All rights reserved.
//

import UIKit
import CocoaLumberjack

class SportsArticleListCell: UITableViewCell {
    @IBOutlet weak var cTitleLbl: UILabel!
    @IBOutlet weak var cDateLbl: UILabel!
    @IBOutlet weak var cImageIV: UIImageView!
    
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureWithData<T>(_ data: T) {

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCellView(isCornerRadius:Bool = false) {
        let cornerRadius: CGFloat = isCornerRadius ? 8.0 : 0.0
        let maskPath = UIBezierPath(
            roundedRect: cellView.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )

        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        cellView.layer.mask = maskLayer
    }
    
}



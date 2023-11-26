//
//  SportsArticleListMoreCell.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/20.
//  Copyright © 2023 Eddie. All rights reserved.
//


import UIKit

class SportsArticleListMoreCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //TODO check 跑版
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCellView()
    }
    
    func configureWithData(title:String){
        self.titleLbl.text = title
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureCellView() {
        // 设置左上角和右上角为圆角
        let cornerRadius: CGFloat = 8.0 // 您可以根据需要调整圆角的半径
        let maskPath = UIBezierPath(
            roundedRect: cellView.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )

        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        cellView.layer.mask = maskLayer
    }
    
}

//
//  CImageCell.swift
//  videoCollection
//
//  Created by TVBS on 2021/7/6.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit

protocol CImageCellDelegate: NSObjectProtocol {
    func imageClick(_ image: String?)
}

class CImageCell: UITableViewCell {
    @IBOutlet weak var mainIV: UIImageView!
    weak var delegate: CImageCellDelegate?
    open var data: ChosenList?
    
    override func awakeFromNib() {
        let mainIVTap = UITapGestureRecognizer(target: self, action: #selector(self.mainIVTap(_:)))
        self.mainIV.isUserInteractionEnabled = true
        self.mainIV.addGestureRecognizer(mainIVTap)
    }
    
    @objc func mainIVTap(_ sender:UITapGestureRecognizer) {
        weak var weakSelf = self
        weakSelf?.delegate?.imageClick(self.data?.image)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithData(_ data: ChosenList?) {
        guard let uwData = data else {
            return
        }
        self.data = uwData
        Util.shared.setImage(mainIV, uwData.image, "content")
    }
    
}

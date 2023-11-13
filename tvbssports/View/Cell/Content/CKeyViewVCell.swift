//
//  CKeyViewVCell.swift
//  videoCollection
//
//  Created by TVBS on 2021/7/6.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit

protocol CKeyViewVCellDelegate: NSObjectProtocol {
    func keyViewClick(_ data: ChosenList?, _ cell: CKeyViewVCell)
}

class CKeyViewVCell: UITableViewCell {
    @IBOutlet weak var keyView: UIImageView!
    weak var delegate: CKeyViewVCellDelegate?
    open var data: ChosenList?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let keyViewTap = UITapGestureRecognizer(target: self, action: #selector(self.keyViewTap(_:)))
        self.keyView.isUserInteractionEnabled = true
        self.keyView.addGestureRecognizer(keyViewTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func keyViewTap(_ sender:UITapGestureRecognizer) {
        weak var weakSelf = self
        weakSelf?.delegate?.keyViewClick(self.data, self)
    }
    
    func configureWithData(_ data: ChosenList?) {
        guard let uwData = data else {
            return
        }
        self.data = uwData
        Util.shared.setImage(keyView, uwData.image, "content")
    }
    
}

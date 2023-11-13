//
//  CKeyViewPCell.swift
//  videoCollection
//
//  Created by TVBS on 2021/7/6.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit

protocol CKeyViewPCellDelegate: NSObjectProtocol {
    func keyViewPClick(_ image: String?)
}

class CKeyViewPCell: UITableViewCell {
    @IBOutlet weak var keyView: UIImageView!
    weak var delegate: CKeyViewPCellDelegate?
    open var data: ChosenList?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let keyViewTap = UITapGestureRecognizer(target: self, action: #selector(self.keyViewTap(_:)))
        self.keyView.isUserInteractionEnabled = true
        self.keyView.addGestureRecognizer(keyViewTap)
    }
    
    @objc func keyViewTap(_ sender:UITapGestureRecognizer) {
        weak var weakSelf = self
        weakSelf?.delegate?.keyViewPClick(self.data?.image)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureWithData(_ data: ChosenList?) {
        guard let uwData = data else {
            return
        }
        self.data = uwData
        Util.shared.setImage(keyView, uwData.image, "content")
    }
    
}

//
//  CAltCell.swift
//  videoCollection
//
//  Created by TVBS on 2021/7/12.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit

class CAltCell: UITableViewCell {
    @IBOutlet weak var cAltLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureWithData(_ data: ChosenList?) {
        guard let uwData = data else {
            return
        }
        cAltLbl.text = uwData.title
    }
}

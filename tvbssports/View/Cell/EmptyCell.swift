//
//  EmptyCell.swift
//  videoCollection
//
//  Created by Oscsr on 2020/12/28.
//  Copyright © 2020 Oscsr. All rights reserved.
//

import UIKit

class EmptyCell: UITableViewCell {
    @IBOutlet weak var bgImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

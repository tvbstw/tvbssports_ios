//
//  ColCategoryCell.swift
//  videoCollection
//
//  Created by Eddie on 2021/12/10.
//  Copyright © 2021 Eddie. All rights reserved.
//

import UIKit

class ColCategoryCell: UICollectionViewCell {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var categoryIV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func configureWithData(_ data: CategoryData) {
        titleLbl.text = data.title
    }
}

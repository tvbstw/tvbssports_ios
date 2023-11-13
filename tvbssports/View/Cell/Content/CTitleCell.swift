//
//  CTitleCell.swift
//  videoCollection
//
//  Created by TVBS on 2021/7/6.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit

class CTitleCell: UITableViewCell {
    @IBOutlet weak var cTitleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithData(_ data: ChosenList?) {
        guard let uwData = data else {
            return
        }
        cTitleLbl.text = uwData.title
        var fontSize = CGFloat(18.0)
        if let titleFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["contentTitle"] {
            fontSize = CGFloat(titleFont)
        }
        cTitleLbl.font = UIFont.boldSystemFont(ofSize: fontSize)
    }
}

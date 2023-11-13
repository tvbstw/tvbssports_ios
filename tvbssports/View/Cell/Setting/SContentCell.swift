//
//  SContentCell.swift
//  videoCollection
//
//  Created by tvbs on 2021/7/16.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit

class SContentCell: UITableViewCell {

    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var editorLbl: UILabel!
    @IBOutlet weak var textLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containView.layer.cornerRadius = 10
        containView.layer.masksToBounds = true
    }
    func configureWithData() {
        
        var titleFontSize = CGFloat(22.0)
        var editorFontSize = CGFloat(14.0)
        var textFontSize = CGFloat(16.0)
        if let titleFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["contentTitle"] {
            titleFontSize = CGFloat(titleFont)
        }
        if let editorFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["contentEdotor"] {
            editorFontSize = CGFloat(editorFont)
        }
        if let textFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["contentText"] {
            textFontSize = CGFloat(textFont)
        }
//        titleLbl.font = UIFont.systemFont(ofSize: titleFontSize)
        titleLbl.font = UIFont.boldSystemFont(ofSize: titleFontSize)
        editorLbl.font = UIFont.systemFont(ofSize: editorFontSize)
        textLbl.font = UIFont.systemFont(ofSize: textFontSize)

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

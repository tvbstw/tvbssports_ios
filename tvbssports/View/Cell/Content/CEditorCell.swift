//
//  CEditorCell.swift
//  videoCollection
//
//  Created by TVBS on 2021/7/6.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit

class CEditorCell: UITableViewCell {
    @IBOutlet weak var cEditorLbl: UILabel!
    
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
        cEditorLbl.text = uwData.title
        var fontSize = CGFloat(18.0)
        if let editorFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["contentEditor"] {
            fontSize = CGFloat(editorFont)
        }
        cEditorLbl.font = UIFont.systemFont(ofSize: fontSize)
    }
}

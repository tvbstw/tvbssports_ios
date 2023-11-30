//
//  PictureContentTitleCell.swift
//  videoCollection
//
//  Created by darrenChiang on 2022/6/24.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit

class PictureContentTitleCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionlabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithData(data:PictureContent?) {
        guard let picture = data else { return }
        titleLabel.text = picture.name
        descriptionlabel.text = picture.description
        setFontSize()
        
        guard let publishAt = picture.publish_at else {
            return
        }
        
        guard let changedPublishAt = publishAt.stringTypeDateConversionFormat("yyyy/MM/dd") else {
            return
        }
        
        timeLabel.text = changedPublishAt
    }
    
    func setFontSize() {
    
        //titlelabel size default is 18
     let titleFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["contentTitle"]
     titleLabel.font = UIFont.boldSystemFont(ofSize: titleFont ?? 24)
        
        //timelabel size default is 18
        let timeFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["contentEditor"]
        timeLabel.font = UIFont.systemFont(ofSize: timeFont ?? 14)
        
        //content text size default is 18
         let textFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["contentText"]
        descriptionlabel.font = UIFont.systemFont(ofSize: textFont ?? 18)
        
    }
}

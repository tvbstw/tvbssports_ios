//
//  SportsArticleListCell.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/20.
//  Copyright © 2023 Eddie. All rights reserved.
//

import UIKit

class SportsArticleListCell: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var shadowView: ShadowView!
    
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

//        shadowView.layer.cornerRadius = 15
//        shadowView.layer.masksToBounds = true
        containView.layer.cornerRadius = 10
        containView.layer.masksToBounds = true
        

    }
    
    //MARK: TimeInterval 今日轉日期字串
    func timeStampString() -> String {
        let date = Date()
        let timeInterval:Int = Int(date.timeIntervalSince1970)
        let timeStamp = Date(timeIntervalSince1970: TimeInterval(timeInterval))
        let timeZone = NSTimeZone.local
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let dateStr = formatter.string(from: timeStamp)
        return dateStr
    }
    func configureWithData() {
//        self.dateLbl.text = self.timeStampString()
        var titleFontSize = CGFloat(18.0)
//        var dateFontSize = CGFloat(14.0)
        if let titleFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["listTitle"] {
            titleFontSize = CGFloat(titleFont)
        }
//        if let dateFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["listDate"] {
//            dateFontSize = CGFloat(dateFont)
//        }
        titleLbl.font = UIFont.systemFont(ofSize: titleFontSize)
//        dateLbl.font = UIFont.systemFont(ofSize: dateFontSize)

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

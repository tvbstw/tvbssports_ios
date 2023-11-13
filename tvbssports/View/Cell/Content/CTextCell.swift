//
//  CTextCell.swift
//  videoCollection
//
//  Created by TVBS on 2021/7/6.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit

protocol CTextCellDelegate: NSObjectProtocol {
    func urlClick(_ str: String)
}

class CTextCell: UITableViewCell {
    @IBOutlet weak var cTextLbl: UILabel!
    fileprivate var newString = NSMutableAttributedString()
    weak var delegate: CTextCellDelegate?
    @IBOutlet var cTextView: UITextView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
     //   let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(_:)))
//        self.cTextView.isUserInteractionEnabled = true
    //    self.cTextView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapLabel(_ sender:UITapGestureRecognizer) {
        weak var weakSelf = self
        if let uwAttributeText = cTextView.attributedText {
            uwAttributeText.enumerateAttributes(in: NSMakeRange(0, uwAttributeText.length), options: .reverse, using: { (attributes, range, _) in
                    if let uwLink = attributes[NSAttributedString.Key.link] as? NSURL {
                        if let uwUrl = uwLink.absoluteString {
                            weakSelf?.delegate?.urlClick(uwUrl)
                        }
                    }
            })
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithData(_ data: ChosenList?) {

        guard let uwData = data else {
            return
        }
        
        //cTextLbl.text = uwData.title
        /*
        if let uwTitle = uwData.title.data(using: String.Encoding.utf8) {
            if let attributedString = try? NSAttributedString(data: uwTitle, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
                cTextLbl.attributedText = attributedString
            }
            var fontSize = CGFloat(18.0)
            if let textFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["contentText"] {
                fontSize = CGFloat(textFont)
            }
            cTextLbl.font = UIFont.systemFont(ofSize: fontSize)
        }
        */
        cTextView.textContainer.lineFragmentPadding = 0
        let paragraphstyle = NSMutableParagraphStyle()
        paragraphstyle.alignment = .justified
        paragraphstyle.lineHeightMultiple = 1.4
        let string = uwData.title.htmlToAttributedString
        guard let unwString = string else { return }
        newString = NSMutableAttributedString(attributedString: unwString)
        let range = NSRange(location: 0, length: unwString.length)
        var fontSize = CGFloat(18.0)
        if let textFont = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["contentText"] {
            fontSize = CGFloat(textFont)
        }
        
        newString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: fontSize) as Any, range: range)
        newString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.textColor, range: range)
        newString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphstyle, range: range)
        
        self.cTextView.linkTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor.selectColor,
                NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue,
            ]

        self.cTextView.attributedText = self.newString
    }

    
}

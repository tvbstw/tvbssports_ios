//
//  ApiStatusCell.swift
//  videoCollection
//
//  Created by Oscsr on 2020/12/28.
//  Copyright © 2020 Oscsr. All rights reserved.
//

import UIKit

protocol ApiStatusCellDelegate: NSObjectProtocol {
    func reloadLblClick()
}

class ApiStatusCell: UITableViewCell {
    
    @IBOutlet weak var sBaseView: UIView!
    @IBOutlet weak var sErrorIV: UIImageView!
    @IBOutlet weak var sErrorMsgLbl: UILabel!
    @IBOutlet weak var sReloadLbl: UILabel!
    weak var delegate:ApiStatusCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.sReloadLbl.layer.borderWidth = 1.0
        self.sReloadLbl.layer.borderColor = UIColor.textColor.cgColor
        self.sReloadLbl.layer.cornerRadius = 15.0
        self.sReloadLbl.layer.masksToBounds = true
        
        self.sErrorMsgLbl.textColor = .textColor
        self.sReloadLbl.textColor = .textColor
        
        let TapAction = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        self.sReloadLbl.isUserInteractionEnabled = true
        self.sReloadLbl.addGestureRecognizer(TapAction)
        
    }
    
    @objc func tap(_ sender:UITapGestureRecognizer) {
        weak var weakSelf = self
        weakSelf?.delegate?.reloadLblClick()
    }
    
    func configureWithData(_ api: [APIStatus]) {
        switch api[0].status {
        case W_EMPTY:
            self.sErrorMsgLbl.text = EMPTY_MESSAGE
            self.sReloadLbl.text = EMPTY_RELOAD_BTN
        case W_ERROR:
            self.sErrorMsgLbl.text = ERROR_MESSAGE
            self.sReloadLbl.text = ERROR_RELOAD_BTN
        case W_UNREACHABLE:
            self.sErrorMsgLbl.text = UNREACHABLE_MESSAGE
            self.sReloadLbl.text = UNREACHABLE_RELOAD_BTN
        default:
            break
        }
    }
    
    func configureWithData(_ errorType: ErrorType) {
        switch errorType {
        case .empty:
            self.sErrorMsgLbl.text = EMPTY_MESSAGE
            self.sReloadLbl.text = EMPTY_RELOAD_BTN
        case .error:
            self.sErrorMsgLbl.text = ERROR_MESSAGE
            self.sReloadLbl.text = ERROR_RELOAD_BTN
        case .unreachable:
            self.sErrorMsgLbl.text = UNREACHABLE_MESSAGE
            self.sReloadLbl.text = UNREACHABLE_RELOAD_BTN
        default:
            break
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }
    

    func restoreStatus() {
        self.sBaseView.backgroundColor = .backgroundColor
    }

}

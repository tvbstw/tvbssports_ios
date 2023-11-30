//
//  ApiStatusView.swift
//  videoCollection
//
//  Created by Woody on 2022/4/13.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit
import SnapKit


protocol ApiStatusViewDelegate: AnyObject {
    func reloadLblClick()
}

class ApiStatusView: UIView {
    
    private let imageView: UIImageView = {
       let iv = UIImageView()
        iv.image = .imgError
        iv.contentMode = .scaleToFill
        return iv
    }()
    private let errorMsgLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .textColor
        lb.textAlignment = .center
        return lb
    }()
    
    private let reloadLabel: UILabel = {
       let lb = UILabel()
        lb.layer.borderWidth = 1.0
        lb.layer.borderColor = UIColor.textColor.cgColor
        lb.layer.cornerRadius = 15.0
        lb.layer.masksToBounds = true
        lb.textColor = .textColor
        lb.textAlignment = .center
        return lb
    }()
    
    weak var delegate:ApiStatusViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubview(imageView)
        addSubview(errorMsgLabel)
        addSubview(reloadLabel)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(imageView.snp_height)
        }

        imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        
        NSLayoutConstraint.activate([NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.6, constant: 0)])
        
        errorMsgLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp_bottom).offset(7)
        }
        
        reloadLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.top.equalTo(errorMsgLabel.snp_bottom).offset(17)
            make.width.equalTo(105)
        }
        
        
        let TapAction = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        reloadLabel.isUserInteractionEnabled = true
        reloadLabel.addGestureRecognizer(TapAction)
    }
    
    
    @objc func tap(_ sender:UITapGestureRecognizer) {
        weak var weakSelf = self
        weakSelf?.delegate?.reloadLblClick()
    }
    
    func configureWithData(_ api: [APIStatus]) {
        switch api[0].status {
        case W_EMPTY:
            errorMsgLabel.text = EMPTY_MESSAGE
            reloadLabel.text = EMPTY_RELOAD_BTN
        case W_ERROR:
            errorMsgLabel.text = ERROR_MESSAGE
            reloadLabel.text = ERROR_RELOAD_BTN
        case W_UNREACHABLE:
            errorMsgLabel.text = UNREACHABLE_MESSAGE
            reloadLabel.text = UNREACHABLE_RELOAD_BTN
        default:
            break
        }
    }
    
    func configureWithData(_ errorType: ErrorType) {
        switch errorType {
        case .empty:
            errorMsgLabel.text = EMPTY_MESSAGE
            reloadLabel.text = EMPTY_RELOAD_BTN
        case .error:
            errorMsgLabel.text = ERROR_MESSAGE
            reloadLabel.text = ERROR_RELOAD_BTN
        case .unreachable:
            errorMsgLabel.text = UNREACHABLE_MESSAGE
            reloadLabel.text = UNREACHABLE_RELOAD_BTN
        default:
            break
        }
    }

}

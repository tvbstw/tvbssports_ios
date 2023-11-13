//
//  LoadingView.swift
//  videoCollection
//
//  Created by Eddie on 2022/2/7.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit
import SnapKit
import CocoaLumberjack

enum ArticleLoadingViewStatus: String {
    case open  = "open"
    case close = "close"
}

class ArticleLoadingView: UIView {
        
    private(set) lazy var loadingLabel: UILabel = {
       let loadinglbl = UILabel()
        loadinglbl.text = "載入中…"
        loadinglbl.textColor = UIColor.selectColor
        loadinglbl.font = UIFont(name: "PingFangTC-Semibold", size: 13.0)
        return loadinglbl
    }()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setLabel() {
        backgroundColor = UIColor.backgroundColor
        addSubview(loadingLabel)
        loadingLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(self)
        }
    }
    
    func status(_ status: ArticleLoadingViewStatus) {
        switch status {
        case .open:
            self.alpha = 1
        case .close:
            UIView.animate(withDuration: 0.25, delay: 0.1) {
                self.alpha = 0
            }
        }
    }
}



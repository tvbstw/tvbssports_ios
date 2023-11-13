//
//  MarqueeView.swift
//  videoCollection
//
//  Created by Eddie on 2022/6/21.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit
import MarqueeLabel
import SnapKit

class MarqueeView: UIView {
    
    private var marqueeContent: String?
    
    lazy var marqueeLabel: MarqueeLabel = {
        let marqueeLabel = MarqueeLabel(frame: CGRect.zero)
        marqueeLabel.text = marqueeContent
        marqueeLabel.textAlignment = .left
        marqueeLabel.textColor = .white
        marqueeLabel.font = UIFont(name: "PingFang TC", size: 19.0)
        marqueeLabel.type = .continuous
        marqueeLabel.speed = .rate(50)
        marqueeLabel.trailingBuffer = 70.0
        return marqueeLabel
    }()
    
    init(content: String) {
        marqueeContent = content
        super.init(frame: CGRect.zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.backgroundColor = UIColor.selectColor
        self.addSubview(marqueeLabel)
        marqueeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalTo(40)
        }
    }
}

//
//  STCarouselCell.swift
//  woman
//
//  Created by Eddie on 2018/4/16.
//  Copyright © 2018年 Eddie. All rights reserved.
//

import UIKit

class STCarouselCell: UITableViewCell {
    @IBOutlet weak var stCarouselView: LLCycleScrollView!
    var imageArr = [String]()
    var titleArr = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addNotification()
    }

    fileprivate func addNotification() {
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("LLCycleScrollViewReload"), object: nil, queue: nil) { (notification) in
            self.stCarouselView.reloadScrollToIndex(targetIndex: 0)
        }
    }
    
    func configureWithData(_ data: [ChosenList]?) {
        
        guard let data = data else {
            return
        }
        
        self.imageArr = [String]()
        self.titleArr = [String]()
        for list in data {
            self.imageArr.append(list.image)
            self.titleArr.append(list.title)
        }
        self.setCarouseView()
    }
    
    func configureWithData(_ data: [ArticleListContent]?) {
        
        guard let data = data else {
            return
        }
        
        self.imageArr = [String]()
        self.titleArr = [String]()
        for list in data {
            self.imageArr.append(list.image ?? "")
            self.titleArr.append(list.title ?? "")
        }
        self.setCarouseView()
    }
    
    
    
    fileprivate func setCarouseView() {
        self.stCarouselView.imagePaths = self.imageArr
        self.stCarouselView.titles = self.titleArr
        self.stCarouselView.imageViewContentMode = .scaleAspectFill
        self.stCarouselView.autoScrollTimeInterval = 4.0
        self.stCarouselView.placeHolderImage = .defaultImage
        self.stCarouselView.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        self.stCarouselView.pageControlBottom = 15
        //self.stCarouselView.pageControlTintColor = UIColor.RGB(255, 255, 255)
        self.stCarouselView.pageControlCurrentPageColor = UIColor.selectColor
        self.stCarouselView.numberOfLines = 2
        self.stCarouselView.titleLeading = 8.0
        
        if self.imageArr.count < 2 {
            self.stCarouselView.autoScroll = false
            self.stCarouselView.pageControl?.isHidden = true
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

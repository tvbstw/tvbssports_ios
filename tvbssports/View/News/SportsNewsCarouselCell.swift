//
//  SportsNewsCarouselCell.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/21.
//  Copyright © 2023 Eddie. All rights reserved.
//


import UIKit

class SportsNewsCarouselCell: UITableViewCell {
    @IBOutlet weak var spCarouselView: LLCycleScrollView!
    var imageArr = [String]()
    var titleArr = [String]()
    var dateArr = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addNotification()
    }

    fileprivate func addNotification() {
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("LLCycleScrollViewReload"), object: nil, queue: nil) { (notification) in
            self.spCarouselView.reloadScrollToIndex(targetIndex: 0)
        }
    }
    
    func configureWithData(_ data: [ChosenList]?) {
        
        guard let data = data else {
            return
        }
        
        self.imageArr = [String]()
        self.titleArr = [String]()
        self.dateArr = [String]()
        for list in data {
            self.imageArr.append(list.image)
            self.titleArr.append(list.title)
            self.dateArr.append(list.dateTime)
        }
        self.setCarouseView()
    }
    
    func configureWithData(_ data: [ArticleListContent]?) {
        
        guard let data = data else {
            return
        }
        
        self.imageArr = [String]()
        self.titleArr = [String]()
        self.dateArr = [String]()
        for list in data {
            self.imageArr.append(list.image ?? "")
            self.titleArr.append(list.title ?? "")
            self.dateArr.append(list.videoTime ?? "")
        }
        self.setCarouseView()
    }
    
    func configureWithData() {
        self.imageArr = [String]()
        self.titleArr = [String]()
        self.dateArr = [String]()
        self.imageArr.append("https://cc.tvbs.com.tw/img/upload/2021/12/21/20211221081425-af1865e5.jpg")
        self.titleArr.append("新聞第一")
        self.dateArr.append("2023/08/23 15:27")
        self.imageArr.append("https://cc.tvbs.com.tw/img/upload/2023/03/05/20230305123442-e8a1c487.jpg")
        self.titleArr.append("新聞第二")
        self.dateArr.append("2023/08/24 15:27")
        self.imageArr.append("https://cc.tvbs.com.tw/img/upload/2023/02/06/20230206182949-daec4719.jpg")
        self.titleArr.append("新聞第三")
        self.dateArr.append("2023/08/25 15:27")
        self.imageArr.append("https://cc.tvbs.com.tw/img/upload/2022/09/22/20220922090647-30004e00.jpg")
        self.titleArr.append("新聞第四")
        self.dateArr.append("2023/08/26 15:27")
        self.imageArr.append("https://cc.tvbs.com.tw/img/upload/2021/07/21/20210721172742-d748c1c0.jpg")
        self.titleArr.append("新聞第五")
        self.dateArr.append("2023/08/27 15:27")
        self.setCarouseView()
    }
    
    
    
    fileprivate func setCarouseView() {
        self.spCarouselView.imagePaths = self.imageArr
        self.spCarouselView.titles = self.titleArr
        self.spCarouselView.dates = self.dateArr
        self.spCarouselView.imageViewContentMode = .scaleAspectFill
        self.spCarouselView.autoScrollTimeInterval = 4.0
        self.spCarouselView.placeHolderImage = .defaultImage
        self.spCarouselView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.spCarouselView.textColor = UIColor.black
        self.spCarouselView.pageControlBottom = 15
        //self.spCarouselView.pageControlTintColor = UIColor.RGB(255, 255, 255)
        self.spCarouselView.pageControlCurrentPageColor = UIColor.selectColor
        self.spCarouselView.numberOfLines = 2
        self.spCarouselView.titleLeading = 8.0
        
        if self.imageArr.count < 2 {
            self.spCarouselView.autoScroll = false
            self.spCarouselView.pageControl?.isHidden = true
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

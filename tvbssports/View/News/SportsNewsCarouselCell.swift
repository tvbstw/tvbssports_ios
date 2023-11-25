//
//  SportsNewsCarouselCell.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/21.
//  Copyright © 2023 Eddie. All rights reserved.
//


import UIKit
import FSPagerView

class SportsNewsCarouselCell: UITableViewCell {
    @IBOutlet weak var stCarouselView: LLCycleScrollView!
    
    var imageArr = [String]()
    var titleArr = [String]()
    let fsPageControl = FSPageControl()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addNotification()
    }
    
    fileprivate func addNotification() {
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("LLCycleScrollViewReload"), object: nil, queue: nil) { (notification) in
            self.stCarouselView.reloadScrollToIndex(targetIndex: 0)
        }
    }
    
//    func configureWithData(_ data: [ChosenList]) {
//        self.imageArr = [String]()
//        self.titleArr = [String]()
//        for list in data {
//            self.imageArr.append(list.image)
//            self.titleArr.append(list.title)
//        }
//        self.setCarouseView()
//    }
    
    func configureWithData() {
        self.imageArr = [String]()
        self.titleArr = [String]()
        self.imageArr.append("https://cc.tvbs.com.tw/img/upload/2021/12/21/20211221081425-af1865e5.jpg")
        self.titleArr.append("新聞第一")
        self.imageArr.append("https://cc.tvbs.com.tw/img/upload/2023/03/05/20230305123442-e8a1c487.jpg")
        self.titleArr.append("新聞第二")
        self.imageArr.append("https://cc.tvbs.com.tw/img/upload/2023/02/06/20230206182949-daec4719.jpg")
        self.titleArr.append("新聞第三")
        self.imageArr.append("https://cc.tvbs.com.tw/img/upload/2022/09/22/20220922090647-30004e00.jpg")
        self.titleArr.append("新聞第四")
        self.imageArr.append("https://cc.tvbs.com.tw/img/upload/2021/07/21/20210721172742-d748c1c0.jpg")
        self.titleArr.append("新聞第五")
        self.setCarouseView()
    }
    
    fileprivate func setCarouseView() {
        self.stCarouselView.imagePaths = self.imageArr
        self.stCarouselView.titles = self.titleArr
        self.stCarouselView.imageViewContentMode = .scaleAspectFill
        self.stCarouselView.autoScrollTimeInterval = 4.0
        self.stCarouselView.placeHolderImage = UIImage(named: "default")
        self.stCarouselView.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        self.stCarouselView.pageControl?.isHidden = true
        createPageControll()
  
        self.stCarouselView.numberOfLines = 2
        self.stCarouselView.titleLeading = 8.0
        
        if self.imageArr.count < 2 {
            self.stCarouselView.autoScroll = false
//            self.stCarouselView.pageControl?.isHidden = true
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
 
    fileprivate func createPageControll() {
        fsPageControl.frame =  CGRect(x: 0, y: 0, width: stCarouselView.frame.width, height: 30)
        self.addSubview(fsPageControl)
//            fsPageControl.backgroundColor = .black
        fsPageControl.numberOfPages = self.imageArr.count
//            fsPageControl.contentHorizontalAlignment = .center
        fsPageControl.itemSpacing = 30
//            fsPageControl.contentInsets = UIEdgeInsets(top: 0, left:50 , bottom: 0, right: 50)
        fsPageControl.hidesForSinglePage = true
        fsPageControl.setImage(UIImage(named:"bar_normal"), for: UIControl.State.normal)
        fsPageControl.setImage(UIImage(named:"bar_selected"), for: UIControl.State.selected)
        fsPageControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            let top = self.stCarouselView.frame.height * 0.065
            make.top.equalTo(self.stCarouselView.snp.bottom).offset(-top)
            make.width.equalToSuperview()
            make.height.equalTo(30)
        }

        fsPageControl.currentPage = 0
//        self.stCarouselView.fsPageControl = fsPageControl
    }
}

 

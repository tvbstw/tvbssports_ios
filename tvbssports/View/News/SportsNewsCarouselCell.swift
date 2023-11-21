//
//  SportsNewsCarouselCell.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/21.
//  Copyright © 2023 Eddie. All rights reserved.
//


import UIKit

class SportsNewsCarouselCell: UITableViewCell {
    @IBOutlet weak var stCarouselView: LLCycleScrollView!
    
    var imageArr = [String]()
    var titleArr = [String]()
//    let fsPageControl = FSPageControl()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addNotification()
    }
    
    fileprivate func addNotification() {
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("LLCycleScrollViewReload"), object: nil, queue: nil) { (notification) in
            self.stCarouselView.reloadScrollToIndex(targetIndex: 0)
        }
    }
    
    func configureWithData(_ data: [ChosenList]) {
        self.imageArr = [String]()
        self.titleArr = [String]()
        for list in data {
            self.imageArr.append(list.image)
            self.titleArr.append(list.title)
        }
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
//        createPageControll()
  
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
    
 
//TODO Oscar
//        fileprivate func createPageControll() {
//            fsPageControl.frame =  CGRect(x: 0, y: 0, width: stCarouselView.frame.width, height: 30)
//            self.addSubview(fsPageControl)
////            fsPageControl.backgroundColor = .black
//            fsPageControl.numberOfPages = self.imageArr.count
////            fsPageControl.contentHorizontalAlignment = .center
//            fsPageControl.itemSpacing = 30
////            fsPageControl.contentInsets = UIEdgeInsets(top: 0, left:50 , bottom: 0, right: 50)
//            fsPageControl.hidesForSinglePage = true
//            fsPageControl.setImage(UIImage(named:"bar_normal"), for: UIControl.State.normal)
//            fsPageControl.setImage(UIImage(named:"bar_selected"), for: UIControl.State.selected)
//            fsPageControl.snp.makeConstraints { (make) in
//                make.centerX.equalToSuperview()
//                let top = self.stCarouselView.frame.height * 0.065
//                make.top.equalTo(self.stCarouselView.snp.bottom).offset(-top)
//                make.width.equalToSuperview()
//                make.height.equalTo(30)
//            }
//
//            fsPageControl.currentPage = 0
//            //self.stCarouselView.fsPageControl = fsPageControl
//        }
}

 

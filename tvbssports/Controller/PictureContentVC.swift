//
//  PictureContentVC.swift
//  videoCollection
//
//  Created by darrenChiang on 2022/6/24.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit
import MJRefresh
import Kingfisher

class PictureContentVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    var picture:PictureList?
    var pictureContent:PictureContent?
    var pictures:[PictureImage]?
    var sKimages = [SKPhoto]()
    var imageSizes = [CGSize?]()
    var shareImage:UIImage?
    fileprivate var header: MJRefreshGifHeader!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initTableView()
        addNotification()
        queryData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let name = picture?.name ?? ""
        let pid = picture?.pictureId ?? 0
        let pictureID = String(pid)
        US.setAnalyticsLogEnvent(event: "show_screen", action: "Img Detail Page", label: "\(name)_\(pictureID)_圖輯內容")
    }
    
    deinit {
        removeNotifications()
    }
    
    func initView() {
        self.navigationItem.hidesBackButton = true
        let btn = UIButton.customBtnForBarButtonItem("left", "", "icon_back")
        btn.addTarget(self, action: #selector(customBackItemClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
        let settingBI = SettingBI()
        self.navigationItem.rightBarButtonItem = settingBI
        self.navigationController?.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor:UIColor.textColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 19.0, weight: .medium)]
        self.navigationItem.title = "鏡頭看世界"
        self.setRefresh()
    }
    
    func initTableView() {
        self.tableView.dataSource      = self
        self.tableView.delegate        = self
        self.tableView?.separatorStyle = .none
        self.tableView?.register(UINib(nibName: "PictureContentTitleCell", bundle: nil), forCellReuseIdentifier: "PictureContentTitleCell")
        self.tableView?.register(UINib(nibName: "PictureContentListCell", bundle: nil), forCellReuseIdentifier: "PictureContentListCell")
        self.tableView.reloadData()
    }
    
    func setRefresh() {
        //下拉更新
        self.header = MJRefreshGifHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.header.backgroundColor = UIColor.backgroundColor
        self.header.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .idle)
        self.header.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .pulling)
        self.header.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .refreshing)
        self.header.stateLabel?.isHidden = true
        self.header.lastUpdatedTimeLabel?.isHidden = true
        self.tableView?.mj_header = self.header
    }
    
    func addNotification() {
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("fontChanged"), object: nil, queue: nil) { (notification) in
           self.tableView?.reloadData()
        }
    }
    
    func removeNotifications() {
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("fontChanged"), object: nil)
    }
    
    func queryData() {
        guard let pictureId = picture?.pictureId  else {
            return
        }
        
        PictureListM.shared.getPictureContent(pictureId: String(pictureId)) { result in
            switch result {
            case .success(let content):
                guard let picture = content[safe: 0] else {
                    return
                }
                self.pictureContent = picture
                self.pictures = picture.pictures
                //因為ui設計，tableview第一列是title，所以差入一個空的PictureImage
                let titlePicture = PictureImage()
                self.pictures?.insert(titlePicture, at:0 )
                self.processSKImages()
                self.tableView.reloadData()
                
            case .failure(let error):
                print("error\(error.description)")
            }
        }
        
        self.tableView?.mj_header?.endRefreshing()
    }
    
    @objc func refresh() {
        queryData()
    }
    
    @objc func customBackItemClick() {
        self.navigationController?.popViewController(animated: true)
    }

    //處理圖輯相簿所需圖片
    func processSKImages() {
        
        guard let pictures = self.pictureContent?.pictures else {
            return
        }
  
        /// 1. create URL Array
        var images = [SKPhoto]()
        
        var imagesSize = [CGSize?]()
        for (index ,picture) in pictures.enumerated() {
            guard let url = picture.image else {
                return
            }
            let photo = SKPhoto.photoWithImageURL(url)
           
            photo.shouldCachePhotoURLImage = true
            photo.caption = picture.text
            images.append(photo)
            
            ///預先取得圖片大小，為了調整圖片顯示比例
            guard let imageUrl = URL(string: url) else {
                return
            }

            let imageSize = self.sizeOfImageAt(url: imageUrl)
            imagesSize.append(imageSize)
        }
        
        self.imageSizes = imagesSize
        self.sKimages = images
        
        
        
        /// 為了分享，先把封面圖先download下來
         print("asdasd---\(picture?.cover_v) ")
        print("asdasd---\(picture?.cover_h) ")
        if let shareImageUrl =  URL(string: picture?.cover_v ?? "" ){
            let resource = ImageResource(downloadURL: shareImageUrl)
             KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
                 switch result {
                 case .success(let value):
                     self.shareImage = value.image
                 case .failure(let error):
                     print("Error: \(error)")
                 }
             }
        }
        
    }
    
// PictureContentVC End
}


extension PictureContentVC :UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pictures?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let data = self.pictures?[safe:indexPath.row] else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PictureContentTitleCell" , for: indexPath) as! PictureContentTitleCell
            cell.configureWithData(data: pictureContent)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PictureContentListCell" , for: indexPath) as! PictureContentListCell
            cell.configureWithData(data: data , imageSize: imageSizes[safe:indexPath.row-1] as? CGSize )
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //第一筆cell 是為了title加上去的cell
        guard indexPath.row != 0 else {
           return
        }

        // 2.setting caption options.
        SKCaptionOptions.numberOfLine = 4
        SKCaptionOptions.captionLocation = .bottom
        // 3. create PhotoBrowser Instance, and present and setting caption options.
        let browser = SKPhotoBrowser(photos: self.sKimages)
        browser.initializePageIndex(indexPath.row - 1)
        present(browser, animated: true, completion: {})
        
        let name = picture?.name ?? ""
        let pid = picture?.pictureId ?? 0
        let pictureID = String(pid)
        US.setAnalyticsLogEnvent(event: "click_img", action: "album_detail", label: "\(name)_\(pictureID)_看相簿_圖輯內容")
    }
    
    func sizeOfImageAt(url: URL) -> CGSize? {
        // with CGImageSource we avoid loading the whole image into memory
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        
        let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, propertiesOptions) as? [CFString: Any] else {
            return nil
        }
        
        if let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
           let height = properties[kCGImagePropertyPixelHeight] as? CGFloat {
            return CGSize(width: width, height: height)
        } else {
            return nil
        }
    }
    
///END
}



extension PictureContentVC: BottomShareViewProtocol {
    
    func shareBtnClick() {
        
        let name = pictureContent?.name ?? ""
        let description = pictureContent?.description ?? ""
        
        let shortUrl = "https://bit.ly/3QUIuMe"

        let shareString = " 看圖說新聞「\(name)」\n\n\n\(description)\n\n用圖片帶您輕鬆掌握國際大小事!快來下載TVBS國際+APP\n\(shortUrl)"

        let image = shareImage
        
        let activity = UIActivityViewController(activityItems: [shareString,image ?? ""], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)

        
        //FA
        let shareFa = "\(name)_\(picture?.pictureId ?? 0)_圖輯內頁"
        US.setShareAnalyticsLogEnvent(contentType: shareFa)

    }

}

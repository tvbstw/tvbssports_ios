//
//  VideoListVC.swift
//  youtubeCollection
//
//  Created by leon on 2020/12/21.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SnapKit
import MJRefresh
import Kingfisher
import KingfisherWebP
import CocoaLumberjack
import MBProgressHUD

class VideoListVC: PlayerVC, IndicatorInfoProvider {
    var itemInfo: IndicatorInfo = ""
    fileprivate var menu:Menu
    fileprivate var cID:String   = ""
    fileprivate var cName:String = ""
    fileprivate var playlistID:String = ""
    fileprivate var category_name:String = ""
    fileprivate var tableView:UITableView?
    fileprivate var header: MJRefreshGifHeader!
    fileprivate var footer: MJRefreshBackGifFooter!
//    fileprivate let videoCell = "videoCell"
    fileprivate let articleListCell = "ArticleListCell"

    fileprivate let apiStatusCell = "apistatusCell"
    fileprivate let noMoreDatacell = "noMoreDataCell"
//    fileprivate var data: PlayListItemObject?
//    fileprivate var dataArr = [PlayListItem]()
    fileprivate var data: ChosenList?
    fileprivate var dataArr = [ChosenList]()
    var nextPage:String = ""
    fileprivate var nextPageToken = ""
    
    
  
    
    init(itemInfo: IndicatorInfo, menu: Menu , category_name: String) {
        self.itemInfo = itemInfo
        self.menu = menu
        self.cID   = Util.shared.checkNil(self.menu.ID)
        self.cName = Util.shared.checkNil(self.menu.name)
        self.category_name = category_name
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        loadData()
        addNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let faEvent  = FaEvent.show_screen.rawValue
        let faAction = "Main Page_\(self.category_name)"
        let faLabel = "首頁_\(self.cName)"
        US.setAnalyticsLogEnvent(event: faEvent, action: faAction, label: faLabel)
    }
    
    deinit {
        self.removeNotification()
    }
    
    func initView() {
        addTableView()
        setRefresh()
        setLoadMore()
    }
    
    func addNotification() {
        weak var weakSelf = self
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { (notification) in
            if notification.object != nil {
                weakSelf?.closePlayerVC()
            }
        }
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name.NSExtensionHostDidEnterBackground, object: nil, queue: nil) { (notification) in
            weakSelf?.removePlayer()
        }
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("reloadKeepUI"), object: nil, queue: nil) { (notification) in

            guard let userInfo = notification.userInfo else {
                return
            }
            if let viewController = userInfo["fromVC"] as? UIViewController {
                if !viewController.isEqual(weakSelf) {
                    weakSelf?.tableView?.reloadData()
                }
            }
        }
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("needScrollToTop"), object: nil, queue: nil) { (notification) in
            guard let userInfo = notification.userInfo else {
                return
            }
            if let viewController = userInfo["controller"] as? UIViewController {
                if viewController.isEqual(weakSelf) {
                    weakSelf?.scrollToTop()
                }
            }
        }
        NOTIFICATION_CENTER.addObserver(forName: NSNotification.Name("WillEnterForeground"), object: nil, queue: nil) { (notification) in
            weakSelf?.removePlayer()
        }
        NOTIFICATION_CENTER.addObserver(forName: NSNotification.Name("AVPlayerViewControllerDismissing"), object: nil, queue: nil) { (notification) in
            weakSelf?.removePlayer()
            VIDEO_ENABLED = true
        }
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("fontChanged"), object: nil, queue: nil) { (notification) in
            weakSelf?.tableView?.reloadData()
        }
    }
    
    func removeNotification() {
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name.NSExtensionHostDidEnterBackground, object: nil)
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("reloadKeepUI"), object: nil)
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("needScrollToTop"), object: nil)
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("WillEnterForeground"), object: nil)
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("AVPlayerViewControllerDismissing"), object: nil)
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("fontChanged"), object: nil)
    }
    
    func addTableView() {
        self.tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.tableView?.separatorStyle = .none
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.backgroundColor = UIColor.backgroundColor
        if #available(iOS 11.0, *) {
            self.tableView?.estimatedSectionHeaderHeight = 0
            self.tableView?.estimatedSectionFooterHeight = 0
            self.tableView?.estimatedRowHeight = 100
        }
        if let unTableView = self.tableView {
            self.view.addSubview(unTableView)
            
            unTableView.snp.makeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets.zero)
            })
            
        }
        
//        self.tableView?.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: videoCell)
        self.tableView?.register(UINib(nibName: "ArticleListVCViewCell", bundle: nil), forCellReuseIdentifier: articleListCell)
        
        self.tableView?.register(UINib(nibName: "NoMoreDataCell", bundle: nil), forCellReuseIdentifier: noMoreDatacell)
        self.tableView?.register(UINib(nibName: "ApiStatusCell", bundle: nil), forCellReuseIdentifier: apiStatusCell)
    }
    
    func setRefresh() {
        self.header = MJRefreshGifHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.header.backgroundColor = UIColor.backgroundColor
        self.header.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .idle)
        self.header.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .pulling)
        self.header.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .refreshing)
        self.header.stateLabel?.isHidden = true
        self.header.lastUpdatedTimeLabel?.isHidden = true
        self.tableView?.mj_header = self.header
    }
    
    func setLoadMore() {
        self.footer = MJRefreshBackGifFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreRefresh))
        self.footer.backgroundColor = UIColor.backgroundColor
        self.footer.isHidden = true
        self.footer.setTitle(LOAD_MORE, for: .idle)
        self.footer.setTitle(RELEASE_TO_LOAD, for: .pulling)
        self.footer.setTitle(LOADING, for: .refreshing)
        self.perform(#selector(showFooter), with: nil, afterDelay: 1.0)
        self.tableView?.mj_footer = self.footer
    }
    
    @objc func refresh() {
        nextPageToken = ""
        loadData()
    }
    
    @objc func loadMoreRefresh() {
        loadMore()
    }
    
    @objc func showFooter() {
        self.footer.isHidden = false
    }
    

    func loadData() {
        guard self.menu.link != nil else { return DDLogError("menu link is nil") }
        VideoListM.shared.getInfo(menu: self.menu) { (response:[ChosenList]) in
            self.dataArr = response
            self.nextPage = VideoListM.shared.nextPage
            self.tableView?.reloadData()
            self.tableView?.mj_header?.endRefreshing()

        }
    }
    
    func loadMore() {
        guard self.menu.link != nil else { return DDLogError("menu link is nil") }
        
        guard self.nextPage != "" else {
            self.tableView?.mj_footer?.endRefreshing()
            return
        }
        VideoListM.shared.getInfo(menu: self.menu, paramters: self.nextPage, completion: { [weak self] (response:[ChosenList]) in
            guard let self = self else { return }
            if response.count > 0 {
                self.nextPage = VideoListM.shared.nextPage
                DispatchQueue.global(qos: .background).async {
                    var loadMoreFlag = false
                    for index in 0..<response.count {
                        if response[index].cellLayout != .apiStatus {
                            self.dataArr.append(response[index])
                            loadMoreFlag = true
                        } else {
                            loadMoreFlag = false
                        }
                    }
                    if loadMoreFlag {
                        DispatchQueue.main.async {
                            self.tableView?.reloadData()
                        }
                    }
                    self.tableView?.mj_footer?.endRefreshing()
                }
            } else {
                self.tableView?.mj_footer?.endRefreshing()
            }
        })
    }
    
    func scrollToTop() {
        //self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        guard let tableView = self.tableView else { return }
        tableView.setContentOffset(.zero, animated: true)
    }

}

extension VideoListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        weak var weakSelf = self
        let data = self.dataArr[indexPath.row]
        switch data.cellLayout {
        case .video:
//            let cell = tableView.dequeueReusableCell(withIdentifier: videoCell, for: indexPath) as! VideoCell
            let cell = tableView.dequeueReusableCell(withIdentifier: articleListCell, for: indexPath) as! ArticleListVCViewCell
            
            cell.fromVC = self
            cell.configureWithData(self.dataArr[indexPath.row])
            cell.selectionStyle = .none
            cell.delegate = weakSelf
            return cell
        case .apiStatus:
            let cell = tableView.dequeueReusableCell(withIdentifier: apiStatusCell, for: indexPath) as! ApiStatusCell
            cell.delegate = weakSelf
            cell.configureWithData(data.apiStatus)
            return cell
        default:
            return UITableViewCell()
        }

    }
}

extension VideoListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = self.dataArr[indexPath.row]
        switch data.cellLayout {
        case .video:
            return UITableView.automaticDimension
        case .apiStatus:
            return tableView.frame.size.height
        default:
            return 0
        }

    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleItem = self.dataArr[indexPath.row]
        if singleItem.cellLayout == .video,
           let cell = tableView.cellForRow(at: indexPath) as? ArticleListVCViewCell{
            guard let videoID = singleItem.videoItem?.videoID else { return }
            guard videoID != "" else { return }
            
            let faEvent  = FaEvent.click_video.rawValue
            let faAction = singleItem.isLive ? "\(self.category_name)_video_live" : "\(self.category_name)_video"
            let faLabel  = singleItem.isLive ? "\(videoID)_影片_直播_\(self.cName)頁" : "\(videoID)_影片_\(self.cName)頁"
            US.setAnalyticsLogEnvent(event: faEvent, action: faAction, label: faLabel)
            
            self.readyToPlay(videoID, cell.ImageView)
        }
    }
}

extension VideoListVC: ApiStatusCellDelegate {
    func reloadLblClick() {
        self.loadData()
    }
}

extension VideoListVC: ArticleListVCViewCellDelegate {
    
    func clickCollectSuccess(videoID: String,categoryName:String,name:String) {
        
        let faEvent  = FaEvent.click_collect.rawValue
        let faAction = "\(self.category_name)_video_collect"
        let faLabel = "\(videoID)_影片_收藏_\(self.cName)頁"
        US.setAnalyticsLogEnvent(event: faEvent, action: faAction, label: faLabel)
    }
    
    func clickCollectCancel(videoID: String,categoryName:String,name:String) {
        
    }
}

//
//  VideoIndexVC.swift
//  videoCollection
//
//  Created by Eddie on 2021/12/9.
//  Copyright © 2021 Eddie. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh
import Kingfisher
import KingfisherWebP
import CocoaLumberjack
import SafariServices


class VideoIndexVC: PlayerVC {
    fileprivate var tableView:UITableView?
    fileprivate var header: MJRefreshGifHeader!
    fileprivate var footer: MJRefreshBackGifFooter!
    fileprivate let videoIndexHeadLineCell = "videoIndexHeadLineCell"
    fileprivate let videoIndexCategoryCell = "videoIndexCategoryCell"
    fileprivate let videoIndexPictureCell  = "videoIndexPictureCell"
    fileprivate let videoCell      = "videoCell"
    fileprivate let newsCell       = "ArticleListCell"
    fileprivate let apiStatusCell  = "apistatusCell"
    fileprivate let noMoreDatacell = "noMoreDataCell"
    fileprivate var dataArr = [ChosenList]()
    fileprivate var nextPage:String = ""
    
    lazy var viewModel: VideoIndexViewModel = {
        return VideoIndexViewModel()
    }()
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initAnnouncement()
        whetherShowAnnouncement()
        initVM()
        addNotification()
        /**
         第一次進APP時runPushOrHeadline notification還沒註冊時需設定Timer執行一次runPushOrHeadline()
         */
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (t) in
            PushVM.shared.runPushOrHeadline(nil)
        }
        
        PushVM.shared.addNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let faEvent  = FaEvent.show_screen.rawValue
        let faAction = "Main Page_index"
        let faLabel = "開啟_首頁"
        US.setAnalyticsLogEnvent(event: faEvent, action: faAction, label: faLabel)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    deinit {
        removeNotification()
    }
    
    //MARK: Custom Methods
    func initAnnouncement() {
        viewModel.dataFetchforMarquee()
    }
    
    func whetherShowAnnouncement() {
        viewModel.checkMarqueeClosure = {[weak self] marquee in
            DispatchQueue.main.async {
                guard let mq = marquee, let isShow = mq.isShow, let content = mq.content else {
                    self?.initView()
                    return
                }
                
                guard isShow && !content.isEmpty else {
                    self?.initView()
                    return
                }
                
                self?.initView(isShow)
                let marqueeView = MarqueeView(content: content)
                self?.view.addSubview(marqueeView)
                marqueeView.snp.makeConstraints { (make) in
                    make.width.equalToSuperview()
                    make.height.equalTo(40)
                }
            }
        }
    }
    
    func initView(_ isShowMarquee: Bool = false) {
        setTableView(isShowMarquee)
        setRefresh()
        setLoadMore()
    }
    
    func initVM() {
        viewModel.reloadTableViewClosure = {[weak self] behavior, indexPaths in
            DispatchQueue.main.async {
                switch behavior {
                case .refresh:
                    self?.tableView?.reloadData()
                    self?.tableView?.mj_header?.endRefreshing()
                case .loadMore:
                    UIView.setAnimationsEnabled(false)
                    self?.tableView?.insertRows(at: indexPaths, with: .none)
                    UIView.setAnimationsEnabled(true)
                    self?.tableView?.mj_footer?.endRefreshing()
                }
            }
        }
        
        viewModel.dataFetch()
    }
    
    func setTableView(_ isShowMarquee: Bool = false) {
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
                if isShowMarquee {
                    make.edges.equalTo(UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0))
                } else {
                    make.edges.equalTo(UIEdgeInsets.zero)
                }
            })
        }
        
        self.tableView?.register(UINib(nibName: "VideoIndexHeadLineCell", bundle: nil), forCellReuseIdentifier: videoIndexHeadLineCell)
        self.tableView?.register(UINib(nibName: "VideoIndexCategoryCell", bundle: nil), forCellReuseIdentifier: videoIndexCategoryCell)
        self.tableView?.register(UINib(nibName: "VideoIndexPictureCell", bundle: nil), forCellReuseIdentifier: videoIndexPictureCell)
        self.tableView?.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: videoCell)
        self.tableView?.register(UINib(nibName: "ArticleListVCViewCell", bundle: nil), forCellReuseIdentifier: newsCell)
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
    
    @objc func refresh() {
        viewModel.dataFetch()
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
    
    @objc func loadMoreRefresh() {
        guard viewModel.nextPage != "" else {
            self.tableView?.mj_footer?.endRefreshing()
            return
        }
        
        viewModel.dataFetch(viewModel.nextPage, .loadMore)
    }
    
    @objc func showFooter() {
        self.footer.isHidden = false
    }
    
    func addNotification() {
        weak var weakSelf = self
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("fontChanged"), object: nil, queue: nil) { (notification) in
            weakSelf?.tableView?.reloadData()
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
    }
    
    func removeNotification() {
        PushVM.shared.removeNotifications()
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("fontChanged"), object: nil)
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("reloadKeepUI"), object: nil)
    }
}

extension VideoIndexVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        weak var weakSelf = self
        let cellVM = viewModel.getCellViewModel(at: indexPath)
        switch cellVM.cellLayout {
        case .headline:
            guard let headlineData = cellVM.headlineData else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: videoIndexHeadLineCell, for: indexPath) as! VideoIndexHeadLineCell
            cell.delegate = weakSelf
            cell.configureWithData(headlineData)
            return cell
        case .live:
            guard let liveData = cellVM.live else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: newsCell, for: indexPath) as! ArticleListVCViewCell
            cell.fromVC = weakSelf
            cell.configureWithLiveData(liveData)
            cell.selectionStyle = .none
            return cell
        case .category:
            guard let categoryData = cellVM.categoryData else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: videoIndexCategoryCell, for: indexPath) as! VideoIndexCategoryCell
            cell.delegate = weakSelf
            cell.configureWithData(categoryData)
            return cell
        case .picture:
            guard let pictureData = cellVM.pictureData else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: videoIndexPictureCell, for: indexPath) as! VideoIndexPictureCell
            cell.delegate = weakSelf
            cell.configureWithData(pictureData)
            return cell
        case .video:
            guard let videoData = cellVM.video else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: videoCell, for: indexPath) as! VideoCell
            cell.fromVC = weakSelf
            cell.configureWithData(videoData)
            cell.selectionStyle = .none
            return cell
        case .news:
            guard let newsData = cellVM.news else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: newsCell, for: indexPath) as! ArticleListVCViewCell
            cell.fromVC = weakSelf
            cell.configureWithData(newsData)
            cell.selectionStyle = .none
            return cell
        case .apiStatus:
            guard let statusData = cellVM.apiStatusData else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: apiStatusCell, for: indexPath) as! ApiStatusCell
            cell.delegate = weakSelf
            cell.configureWithData(statusData)
            return cell
        case .noMoreData:
            let cell = tableView.dequeueReusableCell(withIdentifier: noMoreDatacell, for: indexPath) as! NoMoreDataCell
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension VideoIndexVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellVM = viewModel.getCellViewModel(at: indexPath)
        switch cellVM.cellLayout {
        case .headline:
            return UITableView.automaticDimension
        case .category:
            return 150
        case .picture:
            ///tableviewcell 上下間距4 所以加8
            return 208
        case .video:
            return UITableView.automaticDimension
        case .live, .news:
            return UITableView.automaticDimension
        case .apiStatus:
            return tableView.frame.size.height
        case .noMoreData:
            return UITableView.automaticDimension
        default:
            return 0
        }

    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellVM = viewModel.getCellViewModel(at: indexPath)
        switch cellVM.cellLayout {
        case .live:
            guard let live = cellVM.live, let videoID = live.videoID else { return }
            let cell = tableView.cellForRow(at: indexPath) as! ArticleListVCViewCell
            if videoID != "" && live.isLive {
                US.setAnalyticsLogEnvent(event: FaEvent.click_video.rawValue, action: "index_live", label: "\(videoID)_影片_直播_首頁")
                self.readyToPlay(videoID, cell.ImageView)
            }
        case .video:
            guard let video = cellVM.video, let videoID = video.videoID else { return }
            guard let cell = tableView.cellForRow(at: indexPath) as? VideoCell else { return }
            if videoID != "" {
                US.setAnalyticsLogEnvent(event: FaEvent.click_video.rawValue, action: "index_video", label: "\(videoID)_影片_首頁")
                self.readyToPlay(videoID, cell.mainIV)
            }
        case .news:
            guard let news = cellVM.news, let apiUrl = news.api_url, let title = news.title, let id = news.news_id, let name = news.name else { return }
            US.setAnalyticsLogEnvent(event: FaEvent.click_article.rawValue, action: "index_article", label: "\(title)_\(id)_文章_首頁")
            let vc = ContentVC(apiUrl, name)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

//MARK: ApiStatusCellDelegate
extension VideoIndexVC: ApiStatusCellDelegate {
    func reloadLblClick() {
        viewModel.dataFetch()
    }
}

//MARK: VideoIndexHeadLineCellDelegate
extension VideoIndexVC: VideoIndexHeadLineCellDelegate {
    func clickHeadlineCell(_ data: VideoIndexData,_ index: Int, _ cell: ColHeadLineCell){
        guard let videoID = data.videoID else { return }
        DDLogInfo("⭐️videoID:\(videoID)")
        if videoID != "" {
            US.setAnalyticsLogEnvent(event: "click_video", action: "index_headline_video", label: "\(videoID)_\(index)_頭條_首頁")
            self.readyToPlay(videoID, cell.mainIV)
        } else {
            handHeadlineArticle(data, index)
        }
    }
    
    // MARK: APP-818 [iOS]加入外開功能
    fileprivate func handHeadlineArticle(_ data: VideoIndexData, _ index: Int) {
        guard let apiUrl = data.apiUrl, let newsID = data.newsID, let title = data.title, let name = data.name else { return }
        DDLogInfo("⭐️apiUrl:\(apiUrl)")
        US.setAnalyticsLogEnvent(event: "click_article", action: "index_headline_article", label: "\(title)_\(newsID)_\(index)_頭條_首頁")
           
        switch data.openType {
        case .browser:
            openBrowser(apiUrl)
        case .inAppBrowser:
            let webVC = WebVC(apiUrl)
            self.navigationController?.pushViewController(webVC, animated: true)
        case .native, .none:
            let vc = ContentVC(apiUrl,name)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

//MARK: VideoIndexCategoryCellDelegate
extension VideoIndexVC: VideoIndexCategoryCellDelegate {
    func clickCategoryCell(_ data: CategoryData, _ index: Int) {
        //DDLogInfo("⭐️data.title:\(data.title ?? "")")
        guard let topVC = UIApplication.topViewController() else { return DDLogError("topVC is nil.") }
        
        let sb = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let listVC = sb.instantiateViewController(withIdentifier: "listVC") as! ListVC
        
        if let title = data.title {
            let category_name = data.category_name ?? ""
            US.setAnalyticsLogEnvent(event: "click_cate", action: "index_\(category_name)", label: "\(title)_首頁")
        }
        listVC.moveIndex = index
        listVC.moveToSpecificPage()
        topVC.show(listVC, sender: nil)
        
    }
}

// MARK: OpenUrlLayer
extension VideoIndexVC: OpenBrowserUrlLayer {}


//MARK: VideoIndexPictureCellDelegate
extension VideoIndexVC: VideoIndexPictureCellDelegate {
    func clickPictureCell(_ data: PictureList, _ index: Int) {
        guard let topVC = UIApplication.topViewController() else {
            DDLogError("topVC is nil.")
            return
        }
        
        guard let pictureContentVC = MAINSB.instantiateViewController(withIdentifier: "pictureContentVC") as? PictureContentVC else {
            DDLogError("pictureContentVC is nil.")
            return
        }
        
        pictureContentVC.hidesBottomBarWhenPushed = true
        pictureContentVC.picture = data
        topVC.show(pictureContentVC, sender: nil)
        
        let pictureId = data.pictureId ?? 0
        let title = data.name ?? ""
        US.setAnalyticsLogEnvent(event: "click_img", action: "index_img_content", label: "\(title)_\(pictureId)_圖輯_首頁")
    }
    
    func clickPictureEndcell() {
        SM.tabbarController?.selectedIndex = 2
        US.setAnalyticsLogEnvent(event: "click_img", action: "index_img_more", label: "圖輯_看更多_首頁")
    }
}

//
//  SearchListVC.swift
//  videoCollection
//
//  Created by darren on 2020/12/24.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import MJRefresh

class SearchListVC: PlayerVC {
    
    fileprivate var tableView:UITableView?
    fileprivate var header: MJRefreshGifHeader!
    fileprivate var footer: MJRefreshBackGifFooter!
    var dataList: [ChosenList]?
    var keyword:String?
    var nextPage:String?
 //   var menuID:String?
    var searchTitle: String = ""
    var menuTitle: String = ""
    var categoryName : String = ""
    weak var superParent: SearchTabVC?
    fileprivate let articleListCell = "ArticleListCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        queryData()
        addNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //FA 開啟搜尋結果頁
        guard let key = self.keyword  else {
            return
        }
        
        Util.shared.setAnalyticsLogEnvent(event: FaEvent.show_screen.rawValue, action: "SearchResult_video", label: "\(key)_\(self.searchTitle)搜尋結果")
    }
    
    deinit {
        self.removeNotification()
    }
    
    func initView() {
        setNavigation()
        addTableView()
        setRefresh()
        setLoadMore()
    }
    
    func setNavigation() {
        self.navigationItem.hidesBackButton = true
        let btn = UIButton.customBtnForBarButtonItem("left",self.keyword ?? "", "icon_back")
        btn.addTarget(self, action: #selector(customBackItemClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    @objc func customBackItemClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addNotification() {
        weak var weakSelf = self
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
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("reloadKeepUI"), object: nil)
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("WillEnterForeground"), object: nil)
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("AVPlayerViewControllerDismissing"), object: nil)
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("fontChanged"), object: nil)
    }
    
    //MARK: API
    func queryData() {
        
        guard let keyword = keyword else {
            return
        }
        
        let dict = ["text":keyword]
        
        SearchM.shared.getSearchItemList(paramters: dict, nextPage: nil) { (result) in
            switch result {
            case .success(let list):
                self.dataList = self.refactor(SearchItemList: list)
            case .failure(let error):
                self.dataList = [ChosenList]()
                let list = ChosenList()
                switch error.type {
                case .unreachable:
                    list.cellLayout = .unreachable
                default:
                    list.cellLayout = .apiStatus
                }
                self.dataList?.append(list)
                self.updateBarButtonTitle(count:"0")
            }
            self.tableView?.reloadData()
            self.tableView?.mj_header?.endRefreshing()
        }
    }
    
    func queryMore() {
        SearchM.shared.getSearchItemList(paramters: processParmeters(), nextPage: nil) { (result) in
            switch result {
            case .success(let list):
                guard let uwDataArr = self.dataList else {
                    return
                }
                let initialIndex = uwDataArr.count
                let moreList = self.refactor(SearchItemList: list)
                var indexPaths = [IndexPath]()
                var loadMoreFlag = false
                for data in  moreList {
                    if data.cellLayout != .apiStatus {
                        self.dataList?.append(data)
                        let lastRow = self.dataList!.endIndex - 1
                        indexPaths.append(IndexPath(row: lastRow, section: 0))
                        loadMoreFlag = true
                    } else {
                        loadMoreFlag = false
                    }
                }
                
                if loadMoreFlag {
                    UIView.setAnimationsEnabled(false)
                    self.tableView?.insertRows(at: indexPaths, with: .none)
                    self.tableView?.scrollToRow(at: IndexPath(item: initialIndex - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
                    UIView.setAnimationsEnabled(true)
                }
                self.tableView?.mj_footer?.endRefreshing()
                
            case .failure( _):
                //self.showMessage(title: "", message: error.description)
                self.tableView?.mj_header?.endRefreshing()
            }
            
            self.tableView?.reloadData()
        }
    }
    
    func processParmeters(isNextPage:Bool = true) -> [String:String]? {
        //有nextpage直接當參數
        if let nextPage = self.nextPage  {
            ///有nextPage string組成dictionary
            if  nextPage != "" && isNextPage {
                return URL(string:  nextPage)?.constructParameters()
            }
        }
        return nil
    }
    
    func refactor(SearchItemList:[SearchItemList]?) -> [ChosenList] {
        guard let list = SearchItemList else {
            return [ChosenList]()
        }
       
        var arr = [ChosenList]()
        for data in list {
            switch data.type {
            case "video":
                updateBarButtonTitle(count: data.count)
                guard let videoList = data.data  else {
                    return [ChosenList]()
                }
                
                ///empty
                if videoList.count == 0 {
                    let chosenlist = ChosenList()
                    chosenlist.cellLayout = .empty
                    arr.append(chosenlist)
                    updateBarButtonTitle(count:"0")
                    return arr
                }
                
                for item in videoList {
                    let chosenlist = ChosenList()
                    chosenlist.cellLayout = .video
                    chosenlist.videoItem = item.videoItemContent
                    arr.append(chosenlist)
                }
            case "nextPage":
                if let nextPageArr = data.nextPageData {
                    for nextPage in nextPageArr {
                        let page = nextPage.nextPage
                        self.nextPage = page
                        if page == "" {
                            let list = ChosenList()
                            list.cellLayout = .noMoreData
                            arr.append(list)
                        }
                    }
                }
            default: break
            }
        }
        
        return arr
    }
    
    //MARK: view
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
       // nextPageToken = ""
        queryData()
    }
    
    @objc func loadMoreRefresh() {
        guard self.nextPage != "" else {
            self.tableView?.mj_footer?.endRefreshing()
            return
        }
        queryMore()
    }
    
    @objc func showFooter() {
        self.footer.isHidden = false
    }
   
    func addTableView() {
        self.tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.separatorStyle = .none
        self.tableView?.tableFooterView = UIView(frame: .zero)
        self.tableView?.showsVerticalScrollIndicator = false
        self.tableView?.backgroundColor = UIColor.backgroundColor
        if #available(iOS 11.0, *) {
            self.tableView?.contentInsetAdjustmentBehavior = .never
        }
        
        if let unTableView = self.tableView {
            self.view.addSubview(unTableView)
            unTableView.snp.makeConstraints({ (make) in
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                if #available(iOS 11.0, *) {
                    make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    make.top.equalTo(self.bottomLayoutGuide.snp.top)
                    make.bottom.equalTo(self.bottomLayoutGuide.snp.bottom)
                }
            })
        }
        
        self.tableView?.register(UINib(nibName: "ArticleListVCViewCell", bundle: nil), forCellReuseIdentifier: articleListCell)
        self.tableView?.register(UINib(nibName: "NoMoreDataCell", bundle: nil), forCellReuseIdentifier: "noMoreDataCell")
        self.tableView?.register(UINib(nibName: "ApiStatusCell", bundle: nil), forCellReuseIdentifier: "apistatusCell")
        self.tableView?.register(UINib(nibName: "SearchEmptyCell", bundle: nil), forCellReuseIdentifier: "SearchEmptyCell")
      
#if DEVELOPMENT

#endif
    }
    
    func updateBarButtonTitle(count:String) {
        self.menuTitle = "\(self.searchTitle)(\(count))"
        self.superParent?.titleDict[self.searchTitle] = self.menuTitle
        self.superParent?.reloadButtonBarCellWidth()
    }
}

extension SearchListVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title:  self.superParent?.titleDict[self.searchTitle] ?? self.searchTitle)
    }
}

extension SearchListVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let data = self.dataList?[safe:indexPath.row] else {
            return UITableViewCell()
        }
        weak var weakSelf = self
        switch data.cellLayout {
        case .video:
            let cell = tableView.dequeueReusableCell(withIdentifier: articleListCell, for: indexPath) as! ArticleListVCViewCell
            cell.fromVC = self
            cell.configureWithData(data)
            cell.selectionStyle = .none
            cell.delegate = weakSelf
            return cell
        case .empty:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchEmptyCell",for: indexPath) as! SearchEmptyCell
            return cell
        case.apiStatus:
            let cell = tableView.dequeueReusableCell(withIdentifier: "apistatusCell",for: indexPath) as! ApiStatusCell
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        case.unreachable:
            let cell = tableView.dequeueReusableCell(withIdentifier: "apistatusCell",for: indexPath) as! ApiStatusCell
            cell.selectionStyle = .none
            cell.configureWithData(ErrorType.unreachable)
            cell.delegate = self
            return cell
        case .noMoreData:
            let cell = tableView.dequeueReusableCell(withIdentifier: "noMoreDataCell",for: indexPath) as! NoMoreDataCell
            cell.selectionStyle = .none
            return cell
        default:
            let cell = UITableViewCell()
            cell.backgroundColor = .backgroundColor
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = self.dataList?[indexPath.row]
        switch data?.cellLayout {
        case .noMoreData:
            return CGFloat(0)
        case .video:
            return UITableView.automaticDimension
        default:
            return self.view.bounds.height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.dataList?[indexPath.row]
        guard let videoID = data?.videoItem?.videoID, let cellLayout = data?.cellLayout else {
            return
        }
        if cellLayout == .video,
            let cell = tableView.cellForRow(at: indexPath) as? ArticleListVCViewCell{
            if videoID != "" {
                self.readyToPlay(videoID, cell.ImageView)
            }
            print(data?.videoItem?.name ?? "")
            
            //FA 點擊影片
            guard let key = self.keyword  , let categoryName = data?.videoItem?.categoryName ,let name = data?.videoItem?.name  else {
                return
            }
            
            //【youtube ID】_影片_【關鍵字】_【分類名稱中文】搜尋結果
            Util.shared.setAnalyticsLogEnvent(event: FaEvent.click_video.rawValue, action: "search_result_\(categoryName)_video", label: "\(videoID)_影片_\(key)_\(name)搜尋結果")
            
        }
    }
}

extension SearchListVC: ApiStatusCellDelegate {
    func reloadLblClick() {
        queryData()
    }
}

extension SearchListVC: ArticleListVCViewCellDelegate {
    func clickCollectCancel(videoID: String, categoryName: String, name: String) {
        
    }
    
    func clickCollectSuccess(videoID: String,categoryName:String ,name:String) {
        //FA 收藏影片
        guard let key = self.keyword   else {
            return
        }
        

        
        Util.shared.setAnalyticsLogEnvent(event: FaEvent.click_collect.rawValue, action: "search_result_\(categoryName)_video_collect", label: "\(videoID)_影片_收藏_\(key)_\(name)搜尋結果")
    }
    

}

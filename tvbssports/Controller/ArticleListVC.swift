//
//  ArticleListVC.swift
//  videoCollection
//
//  Created by darrenChiang on 2021/7/1.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit
import MJRefresh
import XLPagerTabStrip

class ArticleListVC: UIViewController {
//    fileprivate var menu:Menu
    fileprivate var cID:String   = ""
    fileprivate var cName:String = ""
    fileprivate let stcarouselcell  = "stcarouselcell"
    fileprivate let noMoreDataCell  = "noMoreDataCell"
    fileprivate let SearchEmptyCell = "SearchEmptyCell"
    fileprivate let ArticleListCell = "ArticleListCell"
    fileprivate let apistatusCell   = "apistatusCell"
    fileprivate var tableView:UITableView?
    fileprivate var searchHeader: MJRefreshGifHeader!
    fileprivate var footer: MJRefreshBackGifFooter!
    var nextPage:String?
    var dataList: [ChosenList]?
    var rotateList:[ArticleListContent]?
    var loadingText: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "文章"
        self.navigationController?.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor:UIColor.textColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 19.0, weight: .medium)]
        addTableView()
        setRefresh()
        setLoadMore()
        setLoadingMsg()
        queryData()
        addNotfication()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let faEvent  = FaEvent.show_screen.rawValue
        let faAction = "Main Page_World"
        let faLabel = "首頁_全球文章列表"
        US.setAnalyticsLogEnvent(event: faEvent, action: faAction, label: faLabel)
    }
    
    deinit {
        self.removeNotfication()
    }
    
    func addNotfication() {
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("fontChanged"), object: nil, queue: nil) { (notification) in
            self.tableView?.reloadData()
        }
    }
    
    func removeNotfication() {
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("fontChanged"), object: nil)
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
                make.edges.equalTo(UIEdgeInsets.zero)
            })
        }
        
        self.tableView?.register(UINib(nibName: "ApiStatusCell", bundle: nil), forCellReuseIdentifier: apistatusCell)
        self.tableView?.register(UINib(nibName: "NoMoreDataCell", bundle: nil), forCellReuseIdentifier: noMoreDataCell)
        self.tableView?.register(UINib(nibName: "SearchEmptyCell", bundle: nil), forCellReuseIdentifier: SearchEmptyCell)
        self.tableView?.register(UINib(nibName: "ArticleListVCViewCell", bundle: nil), forCellReuseIdentifier: ArticleListCell)
        self.tableView?.register(UINib(nibName: "STCarouselCell", bundle: nil), forCellReuseIdentifier: stcarouselcell)
    }
    
    func setRefresh() {
        //下拉更新
        self.searchHeader = MJRefreshGifHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.searchHeader.backgroundColor = UIColor.backgroundColor
        self.searchHeader.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .idle)
        self.searchHeader.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .pulling)
        self.searchHeader.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .refreshing)
        self.searchHeader.stateLabel?.isHidden = true
        self.searchHeader.lastUpdatedTimeLabel?.isHidden = true
        self.tableView?.mj_header = self.searchHeader
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
    
    //MARK: API
    func queryData() {
        self.nextPage = ""
        ArticleListM.shared.getArticleListItem(apiUrl: GLOBALNEWS_API) { (result) in
            switch result {
            case .success(let list):
                self.dataList = self.refactor(ArtcleList: list)
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
            }
            self.closeLoadingMsg()
            self.tableView?.reloadData()
            self.tableView?.mj_header?.endRefreshing()
        }
    }
    
    func queryMore() {
        guard let uwNextPage = self.nextPage else {
            return
        }
        if uwNextPage != "" {
            ArticleListM.shared.getArticleListItem(apiUrl: uwNextPage) { (result) in
                switch result {
                case .success(let list):
                    guard let uwDataArr = self.dataList else {
                        return
                    }
                    let initialIndex = uwDataArr.count
                    let moreList = self.refactor(ArtcleList: list)
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
                    self.tableView?.mj_header?.endRefreshing()
                }
                self.tableView?.reloadData()
            }
        }
    }
    
    func refactor(ArtcleList:[ArticleList]?) -> [ChosenList] {
        
        guard let list = ArtcleList else {
            return [ChosenList]()
        }
       
        var count = [ChosenList]()
        var arr = [ChosenList]()
        for data in list {
            switch data.type {
            case "news":
                guard let newsData = data.newsData  else {
                    return [ChosenList]()
                }
                let chosenlist = ChosenList()
                chosenlist.cellLayout = .artcleList
                chosenlist.artcleItem = newsData
                arr.append(chosenlist)
                count.append(chosenlist)
            
            case "rotate":
                guard let rotateListItem = data.rotateData  else {
                    return [ChosenList]()
                }
                let chosenlist = ChosenList()
                chosenlist.cellLayout = .rotate
                chosenlist.artcleListRotateList = rotateListItem
                self.rotateList = rotateListItem
                arr.append(chosenlist)
                count.append(chosenlist)
                
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
        
        //判斷資料是否為沒數量
        ///empty
        if count.count == 0 {
            let chosenlist = ChosenList()
            chosenlist.cellLayout = .empty
            arr.append(chosenlist)
            return arr
        }
        
        return arr
    }
    
    func setLoadingMsg(){
        self.loadingText = UILabel.init(frame:  CGRect(x: CGFloat(SCREEN_WIDTH/2) - 50, y: (CGFloat(SCREEN_HEIGHT - STATUS_HEIGHT - TABBAR_HEIGHT)/2) - 25, width: 100, height:50))
        self.loadingText?.text = LOADING
        self.loadingText?.textColor = UIColor.selectColor
        self.loadingText?.textAlignment = .center
        if let loading = self.loadingText {
            self.view.addSubview(loading)
        }
    }
    
    func closeLoadingMsg(){
        if self.loadingText != nil {
            self.loadingText?.removeFromSuperview()
        }
    }
    
}

extension ArticleListVC :UITableViewDelegate ,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard  let data = self.dataList?[indexPath.row] else {
            return UITableViewCell()
        }
        
        switch data.cellLayout {
        case .rotate :
            let cell = tableView.dequeueReusableCell(withIdentifier: stcarouselcell, for: indexPath) as! STCarouselCell
            cell.selectionStyle = .none
            cell.configureWithData(data.artcleListRotateList)
            cell.stCarouselView.delegate = self
            cell.selectionStyle = .none
            return cell
        case .artcleList :
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleListCell) as! ArticleListVCViewCell
            cell.isHiddenPlayicon = true
            cell.configureWithData(data.artcleItem)
            cell.selectionStyle = .none
            return cell
        case .apiStatus :
            let cell = tableView.dequeueReusableCell(withIdentifier: apistatusCell, for: indexPath) as! ApiStatusCell
            cell.delegate = self
            cell.configureWithData(data.apiStatus)
            return cell
        case .empty :
            let cell = tableView.dequeueReusableCell(withIdentifier: apistatusCell, for: indexPath) as! ApiStatusCell
            cell.delegate = self
            cell.configureWithData(.empty)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let apiUrl = dataList?[safe:indexPath.row]?.artcleItem?.api_url, let title = dataList?[safe:indexPath.row]?.artcleItem?.title, let newsID = dataList?[safe:indexPath.row]?.artcleItem?.news_id, let category = dataList?[safe:indexPath.row]?.artcleItem?.enName, let categoryCh = dataList?[safe:indexPath.row]?.artcleItem?.name else {
            return
        }
        let faEvent  = FaEvent.click_article.rawValue
        let faAction = "world_article"
        let faLabel = "\(title)_\(newsID)_文章_全球文章列表"
        US.setAnalyticsLogEnvent(event: faEvent, action: faAction, label: faLabel)
        
        let vc = ContentVC(apiUrl,categoryCh)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ArticleListVC : ApiStatusCellDelegate {
    func reloadLblClick() {
        self.queryData()
    }
}

extension ArticleListVC:LLCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, didSelectItemIndex index: NSInteger) {
        guard let apiUrl = rotateList?[safe:index]?.api_url, let title = rotateList?[safe:index]?.title, let newsID = rotateList?[safe:index]?.news_id, let category = rotateList?[safe:index]?.enName, let categoryCh = rotateList?[safe:index]?.name else {
            return
        }
        let faEvent  = FaEvent.click_article.rawValue
        let faAction = "world_article_headline"
        let faLabel = "\(title)_\(newsID)_頭條_全球文章列表"
        US.setAnalyticsLogEnvent(event: faEvent, action: faAction, label: faLabel)
        let vc = ContentVC(apiUrl,categoryCh)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//
//  SportsIndexVC.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/21.
//  Copyright © 2023 Eddie. All rights reserved.
//


import UIKit
import MJRefresh
import XLPagerTabStrip

class SportsIndexVC: UIViewController {
    
    fileprivate let prologueTitleCell = "prologueTitleCell"
    fileprivate let predictRotateCell = "predictRotateCell"
    fileprivate let remainTitle = "remainTitle"
    fileprivate let myRecordCell = "myRecordCell"
    fileprivate let sportsNewsCarouselCell = "sportsNewsCarouselCell"
    fileprivate let sportsArticleListMoreCell = "sportsArticleListMoreCell"
    fileprivate let sportsArticleListCell = "sportsArticleListCell"
    fileprivate let aDBigCardCell = "aDBigCardCell"
    fileprivate let aDBannerCell = "aDBannerCell"
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
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor:UIColor.textColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 19.0, weight: .medium)]
        initView()
//        setupNotchBackground()
        setRefresh()
        addTableView()
        setRefresh()
        setLoadingMsg()
        queryData()
        addNotfication()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let faEvent  = FaEvent.show_screen.rawValue
//        let faAction = "Main Page_World"
//        let faLabel = "首頁_全球文章列表"
//        US.setAnalyticsLogEnvent(event: faEvent, action: faAction, label: faLabel)
    }
    
    deinit {
        self.removeNotfication()
    }
    
    func addNotfication() {

    }
    
    func removeNotfication() {
    }
    
    func initView() {
        self.navigationItem.hidesBackButton = true
        let settingBI = MemberBarItem()
        self.navigationItem.rightBarButtonItem = settingBI
        self.navigationController?.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor:UIColor.textColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 19.0, weight: .medium)]
        self.navigationController?.navigationBar.backgroundColor = UIColor.black
        let supportView = UIView(frame: CGRect(x: 0, y: 0, width: 140, height: 28))
        let logo = UIImageView(image: .logo)
        logo.frame = CGRect(x: 0, y: 0, width: supportView.frame.size.width, height: supportView.frame.size.height)
        supportView.addSubview(logo)
        self.navigationItem.titleView = supportView
        self.navigationItem.titleView?.contentMode = .scaleAspectFit
        
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor.black // 替換為你想要的背景色
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        } else {
            // Fallback on earlier versions
            navigationController?.navigationBar.barTintColor = UIColor.black
        }
        
    }

    @objc func customBackItemClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addTableView() {
        self.tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.separatorStyle = .none
        self.tableView?.tableFooterView = UIView(frame: .zero)
        self.tableView?.showsVerticalScrollIndicator = false
        self.tableView?.backgroundColor = UIColor.tableBackgroundColor
        
        if #available(iOS 11.0, *) {
            self.tableView?.contentInsetAdjustmentBehavior = .never
        }
        
        if let unTableView = self.tableView {
            self.view.addSubview(unTableView)
            unTableView.snp.makeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets.zero)
            })
        }
        
        self.tableView?.register(UINib(nibName: "PredictRotateCell", bundle: nil), forCellReuseIdentifier: predictRotateCell)
        self.tableView?.register(UINib(nibName: "PrologueTitleCell", bundle: nil), forCellReuseIdentifier: prologueTitleCell)
        self.tableView?.register(UINib(nibName: "RemainTitle", bundle: nil), forCellReuseIdentifier: remainTitle)
        self.tableView?.register(UINib(nibName: "MyRecordCell", bundle: nil), forCellReuseIdentifier: myRecordCell)
        self.tableView?.register(UINib(nibName: "SportsNewsCarouselCell", bundle: nil), forCellReuseIdentifier: sportsNewsCarouselCell)
        self.tableView?.register(UINib(nibName: "SportsArticleListMoreCell", bundle: nil), forCellReuseIdentifier: sportsArticleListMoreCell)
        self.tableView?.register(UINib(nibName: "SportsArticleListCell", bundle: nil), forCellReuseIdentifier: sportsArticleListCell)
        self.tableView?.register(UINib(nibName: "ADBigCardCell", bundle: nil), forCellReuseIdentifier: aDBigCardCell)
        self.tableView?.register(UINib(nibName: "ADBannerCell", bundle: nil), forCellReuseIdentifier: aDBannerCell)
        self.tableView?.register(UINib(nibName: "ApiStatusCell", bundle: nil), forCellReuseIdentifier: apistatusCell)
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
    
    @objc func refresh() {
        queryData()
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

extension SportsIndexVC :UITableViewDelegate ,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 17
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard  (self.dataList?[indexPath.row]) != nil else {
            return UITableViewCell()
        }
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: prologueTitleCell, for: indexPath) as! PrologueTitleCell
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: predictRotateCell, for: indexPath) as! PredictRotateCell
            cell.selectionStyle = .none
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: remainTitle, for: indexPath) as! RemainTitle
            cell.selectionStyle = .none
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: myRecordCell, for: indexPath) as! MyRecordCell
            cell.selectionStyle = .none
            return cell
        //TODO 熱門新聞
//        case 4:
//            let cell = tableView.dequeueReusableCell(withIdentifier: sportsNewsCarouselCell, for: indexPath) as! SportsNewsCarouselCell
//            cell.configureWithData()
////            cell.stCarouselView.delegate = self
//            cell.selectionStyle = .none
//            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aDBigCardCell", for: indexPath) as! ADBigCardCell
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sportsArticleListMoreCell", for: indexPath) as! SportsArticleListMoreCell
            cell.selectionStyle = .none
            cell.configureWithData(title: "NBA")
            return cell
        case 6,7,8,9,10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sportsArticleListCell", for: indexPath) as! SportsArticleListCell
            cell.selectionStyle = .none
            return cell
        case 11:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sportsArticleListMoreCell", for: indexPath) as! SportsArticleListMoreCell
            cell.selectionStyle = .none
            cell.configureWithData(title: "MLB")
            return cell
        case 12,13,14,15,16:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sportsArticleListCell", for: indexPath) as! SportsArticleListCell
            cell.selectionStyle = .none
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 5, 11:
            if let sportsCell = cell as? SportsArticleListMoreCell {
                sportsCell.selectionStyle = .none
                sportsCell.configureCellView()
            }
            
        case 10, 16:
            if let sportsCell = cell as? SportsArticleListCell {
                sportsCell.selectionStyle = .none
                sportsCell.configureCellView(isCornerRadius: true)
            }
        default:
            break
        }
    }

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1 {
            return 200
        } else if indexPath.row == 4 {
            return 370
        } else{
            return UITableView.automaticDimension
        }
        
        
    }
    
}

extension SportsIndexVC : ApiStatusCellDelegate {
    func reloadLblClick() {
        self.queryData()
    }
}

extension SportsIndexVC:LLCycleScrollViewDelegate {
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

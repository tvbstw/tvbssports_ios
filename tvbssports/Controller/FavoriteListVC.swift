//
//  FavoriteListVC.swift
//  videoCollection
//
//  Created by Oscsr on 2020/12/24.
//  Copyright © 2020 Oscsr. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SnapKit
import CocoaLumberjack
import Kingfisher
import KingfisherWebP
import MJRefresh


class FavoriteListVC: PlayerVC, IndicatorInfoProvider{
    var itemInfo: IndicatorInfo = ""
    fileprivate var tableView:UITableView?
    fileprivate var header: MJRefreshGifHeader!
    fileprivate var nextPage:String = ""
    fileprivate var dataArr = [ChosenList]()
    fileprivate let articleListCell = "ArticleListCell"
    fileprivate let emptyCell = "emptyCell"
    fileprivate let noMoreDataCell = "noMoreDataCell"
    var pagerTabFlag: String = ""
    var pagerTabTitle: String = ""
    fileprivate var videoBtnTitleTotalnum: Int = 0
    fileprivate var superParent: ButtonBarPagerTabStripViewController
    var fromVC:String?
    
    init(itemInfo: IndicatorInfo, parent: ButtonBarPagerTabStripViewController) {
        self.itemInfo = itemInfo
        self.pagerTabFlag = ""
        self.superParent = parent
        self.pagerTabTitle = "收藏"
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.removeNotification()
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
        NOTIFICATION_CENTER.addObserver(forName: NSNotification.Name("reloadFavoriteList"), object: nil, queue: nil) { (notification) in
            weakSelf?.loadData()
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
        NOTIFICATION_CENTER.removeObserver(self, name: NSNotification.Name("reloadFavoriteList"), object: nil)
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("WillEnterForeground"), object: nil)
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("AVPlayerViewControllerDismissing"), object: nil)
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("fontChanged"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fromVC = "\(self.classForCoder)"
        self.addTableView()
        if #available(iOS 11.0, *) {
            self.tableView?.contentInsetAdjustmentBehavior = .never
        }
        initView()
        loadData()
        addNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //FA
        US.setAnalyticsLogEnvent(event: FaEvent.show_screen.rawValue, action: "My Collect Page_video", label: "開啟_收藏頁")
    }
    
    func initView() {
        addTableView()
        addRefresh()
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func loadData() {
        self.dataArr = DBS.queryFavoriteByMenuID(self.pagerTabFlag)
        self.videoBtnTitleTotalnum = self.dataArr.count
        if self.dataArr.count == 0 {
            let list = ChosenList()
            list.cellLayout = .empty
            dataArr.append(list)
        } else {
            let list = ChosenList()
            list.cellLayout = .noMoreData
            self.dataArr.append(list)
        }
        self.reloadPagerTabButton(title: "\(self.pagerTabTitle) (\(self.videoBtnTitleTotalnum))")
        self.tableView?.reloadData()
        self.tableView?.mj_header?.endRefreshing()
    }
    
    func addRefresh() {
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
    
    @objc func refresh() {
        self.loadData()
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
        
        self.tableView?.register(UINib(nibName: "ArticleListVCViewCell", bundle: nil), forCellReuseIdentifier: articleListCell)
        self.tableView?.register(UINib(nibName: "EmptyCell", bundle: nil), forCellReuseIdentifier: emptyCell)
        self.tableView?.register(UINib(nibName: "NoMoreDataCell", bundle: nil), forCellReuseIdentifier: noMoreDataCell)
        
        
    }
    
    func swipeCellDelete(indexPath: IndexPath, tableView: UITableView, data: ChosenList) {
        DBS.unfavorite(newsData: data) { flag in
            if flag {
                self.updateFavoritesUI()                                            //更新收藏UI
                self.removeDataForRows(indexPath: indexPath, tableView: tableView)  //移除畫面資更並更新UI
                self.updateCategoryHeaderAndQuantity()                              //更新類別與數量
                self.updateTableViewStatus(indexPath: indexPath)                    //更新表格狀態
                self.insertLogEnvent(indexPath: indexPath)                          //插入FA
            }
        }
    }
    
    func updateFavoritesUI(){
        NOTIFICATION_CENTER.post(name: NSNotification.Name("reloadKeepUI"),object: nil,userInfo:["fromVC":self as Any])
    }
    
    func insertLogEnvent(indexPath: IndexPath) {
        if let videoID = self.dataArr[indexPath.row].videoItem?.videoID {
            US.setAnalyticsLogEnvent(event: FaEvent.click_cancel.rawValue, action: "my_collect_cancel_video_collect", label: "\(videoID)_影片_取消_收藏_收藏頁")
        }
    }
    
    func removeDataForRows(indexPath: IndexPath,  tableView: UITableView){
        guard self.dataArr.indices.contains(indexPath.row) else { return }
        self.dataArr.remove(at: indexPath.row)
        tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0) as IndexPath], with: UITableView.RowAnimation.bottom)
        tableView.reloadData()
    }
    
    func updateCategoryHeaderAndQuantity() {
        self.videoBtnTitleTotalnum = self.videoBtnTitleTotalnum - 1
        self.reloadPagerTabButton(title: "\(self.pagerTabTitle) (\(self.videoBtnTitleTotalnum))")
    }
    
    func updateTableViewStatus(indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.dataArr.count == 0 {
                self.loadData()
            } else if self.dataArr.count == 1 {
                guard self.dataArr.indices.contains(indexPath.row) else { return }
                let data = self.dataArr[indexPath.row]
                switch data.cellLayout {
                case .apiStatus, .empty, .noMoreData:
                    self.loadData()
                default:
                    break
                }
            }
        }
    }
    
    func reloadPagerTabButton(title: String) {
        self.itemInfo.title = title
        self.superParent.buttonBarView.reloadData()
    }
    
    // MARK: Rotate
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get {
            return .portrait
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FavoriteListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        weak var weakSelf = self
        let data = self.dataArr[indexPath.row]
        switch data.cellLayout {
        case .video:
            let cell = tableView.dequeueReusableCell(withIdentifier: articleListCell, for: indexPath) as! ArticleListVCViewCell
            cell.fromVC = self
            cell.configureWithData(data)
            cell.selectionStyle = .none
            cell.delegate = weakSelf
            cell.favIV.isHidden = true
            cell.favView.isHidden = true
            cell.backgroundColor = UIColor.backgroundColor
            return cell
        case .empty:
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCell, for: indexPath) as! EmptyCell
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension FavoriteListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath)
        switch cell {
        case is ArticleListVCViewCell:
            return true
        default:
            return false
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "            ") { action, index in
            let data = self.dataArr[indexPath.row]
            let cell = tableView.cellForRow(at: indexPath)
            cell?.backgroundColor = UIColor.backgroundColor
            switch cell {
            case is ArticleListVCViewCell:
                    self.swipeCellDelete(indexPath: indexPath, tableView: tableView, data: data)
            default: break
            }
        }

        delete.backgroundColor = UIColor(patternImage: Util.shared.swipeCellButtons(tableView, indexPath))

        return [delete]
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        for subview in tableView.subviews {
            if String(describing: subview).range(of: "UISwipeActionPullView") != nil {
                subview.backgroundColor = UIColor.clear
            }
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = self.dataArr[indexPath.row]
        switch data.cellLayout {
        case .video :
            if let videoID = data.videoItem?.videoID,
               let cell = tableView.cellForRow(at: indexPath) as? ArticleListVCViewCell {
                if videoID != "" {
                    self.readyToPlay(videoID, cell.ImageView)
                    US.setAnalyticsLogEnvent(event: FaEvent.click_video.rawValue, action: "my_collect_video", label: "\(videoID)_影片_收藏_收藏頁")
                }
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = self.dataArr[indexPath.row]
        switch data.cellLayout {
        case .video:
            return UITableView.automaticDimension
        case .empty:
            return tableView.frame.size.height
        default:
            return 0
        }
    }
}

extension FavoriteListVC: ApiStatusCellDelegate {
    func reloadLblClick() {
        self.loadData()
    }
}

extension FavoriteListVC: ArticleListVCViewCellDelegate {
    func clickCollectSuccess(videoID: String,categoryName:String ,name:String) {
        
    }
    
    func clickCollectCancel(videoID: String,categoryName:String,name:String) {
        
    }
}

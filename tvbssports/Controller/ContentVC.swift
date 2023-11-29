//
//  ContentVC.swift
//  videoCollection
//
//  Created by TVBS on 2021/7/2.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Kingfisher
import KingfisherWebP
import MJRefresh

class ContentVC: UIViewController {
    fileprivate var newsTitle:String = ""
    fileprivate var newsID:String = ""
    fileprivate var shareUrl:String = ""
    open var apiUrl:String = ""
    open var navTitle:String = ""
    fileprivate var tableView: UITableView?
    fileprivate var header: MJRefreshGifHeader!
    var dataList: [ChosenList]?
    fileprivate weak var player: VideoIDPlayer?
    fileprivate var skImgArr = [SKPhotoProtocol]()
    fileprivate var imgArr = [String]()
    fileprivate let apiStatusCell = "apistatusCell"
    fileprivate let cKeyViewPCell = "cKeyViewPCell"
    fileprivate let cKeyViewVCell = "cKeyViewVCell"
    fileprivate let cTitleCell = "cTitleCell"
    fileprivate let cEditorCell = "cEditorCell"
    fileprivate let cDateCell = "cDateCell"
    fileprivate let cTextCell = "cTextCell"
    fileprivate let cImageCell = "cImageCell"
    fileprivate let cAltCell = "cAltCell"
    fileprivate let articleListCell = "ArticleListCell"
    fileprivate let extraHeaderCell = "ExtraHeaderCell"
    fileprivate let loadingView: ArticleLoadingView = ArticleLoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        loadData()
        addNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //離開影片全螢幕播放時需加上這段，否則layout會跑掉
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.window?.rootViewController?.view.frame = UIScreen.main.bounds
    }
    
    init(_ apiUrl: String,_ navTitle: String) {
        self.apiUrl = apiUrl
        self.navTitle = navTitle
        super.init(nibName: nil, bundle: nil)
        self.hiddenBottomBar()
    }
    
    deinit {
        DDLogInfo("deinit")
        self.removeNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    private func hiddenBottomBar() {
        hidesBottomBarWhenPushed = true
    }
    
    func addNotification() {
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("fontChanged"), object: nil, queue: nil) { (notification) in
           self.tableView?.reloadData()
        }
    }
    
    func removeNotifications() {
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("fontChanged"), object: nil)
    }
    
    func initView() {
        self.view.backgroundColor = UIColor.backgroundColor
        addTableView()
        setRefresh()
        setNavigation()
        //setLoadingView()
    }
    
    func addTableView() {
        self.tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.separatorStyle = .none
        self.tableView?.tableFooterView = UIView(frame: .zero)
        self.tableView?.showsVerticalScrollIndicator = false
        self.tableView?.backgroundColor = UIColor.backgroundColor
        self.tableView?.estimatedRowHeight = 40
        
        if #available(iOS 11.0, *) {
            self.tableView?.contentInsetAdjustmentBehavior = .never
        }
        
        if let unTableView = self.tableView {
            self.view.addSubview(unTableView)
            unTableView.snp.makeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0))
            })
        }
        
        
        let bottomView = BottomShareView()
        bottomView.delegate = self
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(80)
        }
        
        
        self.tableView?.register(UINib(nibName: "ApiStatusCell", bundle: nil), forCellReuseIdentifier: apiStatusCell)
        self.tableView?.register(UINib(nibName: "CKeyViewPCell", bundle: nil), forCellReuseIdentifier: cKeyViewPCell)
        self.tableView?.register(UINib(nibName: "CKeyViewVCell", bundle: nil), forCellReuseIdentifier: cKeyViewVCell)
        self.tableView?.register(UINib(nibName: "CTitleCell", bundle: nil), forCellReuseIdentifier: cTitleCell)
        self.tableView?.register(UINib(nibName: "CEditorCell", bundle: nil), forCellReuseIdentifier: cEditorCell)
        self.tableView?.register(UINib(nibName: "CDateCell", bundle: nil), forCellReuseIdentifier: cDateCell)
        self.tableView?.register(UINib(nibName: "CTextCell", bundle: nil), forCellReuseIdentifier: cTextCell)
        self.tableView?.register(UINib(nibName: "CImageCell", bundle: nil), forCellReuseIdentifier: cImageCell)
        self.tableView?.register(UINib(nibName: "CAltCell", bundle: nil), forCellReuseIdentifier: cAltCell)
        self.tableView?.register(UINib(nibName: "ArticleListVCViewCell", bundle: nil), forCellReuseIdentifier: articleListCell)
        self.tableView?.register(UINib(nibName: "ExtraHeaderCell", bundle: nil), forCellReuseIdentifier: extraHeaderCell)
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
    
    func setNavigation() {
        self.navigationItem.hidesBackButton = true
        let btn = UIButton.customBtnForBarButtonItem("left", "", "icon_back")
        btn.addTarget(self, action: #selector(customBackItemClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
        let settingBI = SettingBI()
        self.navigationItem.rightBarButtonItem = settingBI
        self.navigationController?.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor:UIColor.textColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 19.0, weight: .medium)]
        self.navigationItem.title = self.navTitle
    }
    
    @objc func customBackItemClick() {
        guard !self.isModal else {
            self.dismiss(animated: false, completion: nil)
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func refresh() {
        loadData()
    }
    
    func setLoadingView() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
    }
    
    func loadData() {
        self.dataList?.removeAll()
        self.skImgArr.removeAll()
        self.imgArr.removeAll()
        self.tableView?.reloadData()
        ContentM.shared.getContent(apiUrl: self.apiUrl) { (result) in
            switch result {
                case .success(let list):
                    //print("list:\(list)")
                    self.dataList = self.refactor(list)
                case .failure(let error):
                    //print("error:\(error)")
                    self.dataList = [ChosenList]()
                    let list = ChosenList()
                    switch error.type {
                        case .unreachable:
                            list.cellLayout = .unreachable
                            list.apiStatus = .unreachable
                        default:
                            list.cellLayout = .apiStatus
                            list.apiStatus = .error
                    }
                    self.dataList?.append(list)
            }
            self.tableView?.reloadData()
            //self.loadingView.status(.close)
            self.tableView?.mj_header?.endRefreshing()
        }
    }
    
    func refactor(_ list:Content?) -> [ChosenList] {
        guard let uwList = list else {
            let chosenList = ChosenList()
            chosenList.cellLayout = .apiStatus
            return [chosenList]
        }
        guard let uwData = uwList.data else {
            let chosenList = ChosenList()
            chosenList.cellLayout = .apiStatus
            return [chosenList]
        }
        var arr = [ChosenList]()
        let uwArticleID = Util.shared.checkNil(uwData.articleID)
        let uwVideoID = Util.shared.checkNil(uwData.videoID)
        let uwVideoImage = Util.shared.checkNil(uwData.videoImg)
        let uwTitle = Util.shared.checkNil(uwData.title)
        let uwEditor = Util.shared.checkNil(uwData.userEcho)
        let uwPublish = Util.shared.checkNil(uwData.publish)
        let _ = Util.shared.checkNil(uwData.categoryLabel)
        let uwCategoryName = Util.shared.checkNil(uwData.categoryName)
        
        self.shareUrl = Util.shared.checkNil(uwData.shareUrl)
        self.newsID = uwArticleID
        self.newsTitle = uwTitle
   
        
        let faEvent  = FaEvent.show_screen.rawValue
        let faAction = "Article Detail Page_World"
        let faLabel = "\(uwTitle)_\(uwArticleID)_文章內頁"
        US.setAnalyticsLogEnvent(event: faEvent, action: faAction, label: faLabel)
        
        if uwCategoryName != "" {
            self.title = uwCategoryName
        }
        
        //影片
        if uwVideoID != "" {
            let chosenList = ChosenList()
            chosenList.cellLayout = .content
            chosenList.contentType = .keyViewV
            chosenList.ID = uwVideoID
            if uwVideoImage != "" {
                chosenList.image = uwVideoImage
            }
            arr.append(chosenList)
        //主圖
        } else {
            let uwImage = Util.shared.checkNil(uwData.image)
            if uwImage != "" {
                let chosenList = ChosenList()
                chosenList.cellLayout = .content
                chosenList.contentType = .keyViewP
                chosenList.image = uwImage
                arr.append(chosenList)
            }
        }
        
        //標題
        if uwTitle != "" {
            let chosenList = ChosenList()
            chosenList.cellLayout = .content
            chosenList.contentType = .title
            chosenList.title = uwTitle
            arr.append(chosenList)
        }
        
        //報導
        if uwEditor != "" {
            let chosenList = ChosenList()
            chosenList.cellLayout = .content
            chosenList.contentType = .editor
            chosenList.title = uwEditor
            arr.append(chosenList)
        }
        
        //日期
        if uwPublish != "" {
            let chosenList = ChosenList()
            chosenList.cellLayout = .content
            chosenList.contentType = .date
            chosenList.title = uwPublish
            arr.append(chosenList)
        }
        
        //內文or圖片
        if let uwContentArr = uwData.nativeContentArr {
            for singleContent in uwContentArr {
                let chosenList = ChosenList()
                chosenList.cellLayout = .content
                switch singleContent.type {
                    case "text":
                        if let uwImgTitle = singleContent.value {
                            chosenList.contentType = .text
                            chosenList.title = uwImgTitle
                            arr.append(chosenList)
                        }
                    case "img":
                        if let uwImage = singleContent.value {
                            chosenList.contentType = .image
                            chosenList.image = uwImage
                            arr.append(chosenList)
                            if let uwAlt = singleContent.alt {
                                if uwAlt != "" {
                                    let textList = ChosenList()
                                    textList.cellLayout = .content
                                    textList.contentType = .alt
                                    textList.title = uwAlt
                                    arr.append(textList)
                                }
                            }
                        }
                    default:break
                }
            }
        }
        
        //圖籍
        guard let uwImgList = uwData.imgList else {
            return arr
        }
        for imgStr in uwImgList {
            let photo = SKPhoto.photoWithImageURL(imgStr, holder: UIImage(named: "default_3"))
            skImgArr.append(photo)
            imgArr.append(imgStr)
        }
        
        //延伸閱讀
        if let uwExtensionArr = uwData.extensionArr {
            if uwExtensionArr.count > 0 {
                //加入 title
                let chosenListExtraHeader = ChosenList()
                chosenListExtraHeader.cellLayout = .extraHeader
                arr.append(chosenListExtraHeader)
                
                for singleExtension in uwExtensionArr {
                    if let _ = singleExtension.image, let _ =  singleExtension.title, let _ = singleExtension.news_id, let _ = singleExtension.publish {
                        let chosenList = ChosenList()
                        chosenList.cellLayout = .artcleList
                        chosenList.artcleItem = singleExtension
                        arr.append(chosenList)
                    }
                }
            }
        }
        
        return arr
    }
    
    func closePlayerVC() {
        player?.pauseVideo()
    }
    
}

extension ContentVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        weak var weakSelf = self
        if let data = self.dataList?[indexPath.row] {
            switch data.cellLayout {
                case .apiStatus, .unreachable:
                    let cell = tableView.dequeueReusableCell(withIdentifier: apiStatusCell, for: indexPath) as! ApiStatusCell
                    cell.delegate = self
                    cell.configureWithData(data.apiStatus)
                    return cell
                case .content:
                    switch data.contentType {
                        case .keyViewV:
                            let cell = tableView.dequeueReusableCell(withIdentifier: cKeyViewVCell, for: indexPath) as! CKeyViewVCell
                            cell.configureWithData(data)
                            cell.delegate = weakSelf
                            cell.selectionStyle = .none
                            return cell
                        case .keyViewP:
                            let cell = tableView.dequeueReusableCell(withIdentifier: cKeyViewPCell, for: indexPath) as! CKeyViewPCell
                            cell.configureWithData(data)
                            cell.delegate = weakSelf
                            cell.selectionStyle = .none
                            return cell
                        case .title:
                            let cell = tableView.dequeueReusableCell(withIdentifier: cTitleCell, for: indexPath) as! CTitleCell
                            cell.configureWithData(data)
                            cell.selectionStyle = .none
                            return cell
                        case .editor:
                            let cell = tableView.dequeueReusableCell(withIdentifier: cEditorCell, for: indexPath) as! CEditorCell
                            cell.configureWithData(data)
                            cell.selectionStyle = .none
                            return cell
                        case .date:
                            let cell = tableView.dequeueReusableCell(withIdentifier: cDateCell, for: indexPath) as! CDateCell
                            cell.configureWithData(data)
                            cell.selectionStyle = .none
                            return cell
                        case .text:
                            let cell = tableView.dequeueReusableCell(withIdentifier: cTextCell, for: indexPath) as! CTextCell
                            cell.configureWithData(data)
                            cell.delegate = weakSelf
                            cell.selectionStyle = .none
                            return cell
                        case .image:
                            let cell = tableView.dequeueReusableCell(withIdentifier: cImageCell, for: indexPath) as! CImageCell
                            cell.configureWithData(data)
                            cell.delegate = weakSelf
                            cell.selectionStyle = .none
                            return cell
                        case .alt:
                            let cell = tableView.dequeueReusableCell(withIdentifier: cAltCell, for: indexPath) as! CAltCell
                            cell.configureWithData(data)
                            cell.selectionStyle = .none
                            return cell
                        default:
                            break
                    }
                    
                case .extraHeader:
                    let cell = tableView.dequeueReusableCell(withIdentifier: extraHeaderCell, for: indexPath) as! ExtraHeaderCell
                    cell.selectionStyle = .none
                    return cell
                
                case .artcleList:
                    let cell = tableView.dequeueReusableCell(withIdentifier: articleListCell, for: indexPath) as! ArticleListVCViewCell
                    cell.isHiddenPlayicon = true
                    cell.configureWithData(data.artcleItem)
                    cell.selectionStyle = .none
                    return cell
                
                default:
                    return UITableViewCell()
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let apiUrl = dataList?[safe:indexPath.row]?.artcleItem?.api_url, let title = dataList?[safe:indexPath.row]?.artcleItem?.title, let newsID = dataList?[safe:indexPath.row]?.artcleItem?.news_id, let name = dataList?[safe:indexPath.row]?.artcleItem?.name else {
            return
        }
        let faEvent  = FaEvent.click_article.rawValue
        let faAction = "article_detail_related"
        let faLabel = "\(title)_\(newsID)_文章_延伸閱讀_文章內頁"
        US.setAnalyticsLogEnvent(event: faEvent, action: faAction, label: faLabel)
        //self.loadingView.status(.open)
        //20211227 Eddie APP-619 進入文章內頁第N層，Click返回，應回到第一層
        self.apiUrl = apiUrl
        self.navTitle = name
        loadData()
    }
    
    
}

extension ContentVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let data = self.dataList?[indexPath.row] {
            switch data.cellLayout {
            case .apiStatus, .unreachable:
                return tableView.frame.size.height
            case .content:
                return UITableView.automaticDimension
            default:
                return UITableView.automaticDimension
            }
        }
        return UITableView.automaticDimension
    }
}

extension ContentVC: ApiStatusCellDelegate {
    func reloadLblClick() {
        loadData()
    }
}

extension ContentVC: CKeyViewPCellDelegate{
    func keyViewPClick(_ image: String?) {
        guard let uwImage = image else {
            return
        }
        var pageIndex = 0
        for (index, value) in imgArr.enumerated() {
            if value == image {
                pageIndex = index
                break
            }
        }
        let browser = SKPhotoBrowser(photos: (skImgArr), initialPageIndex: pageIndex)
        if let uwIndex = imgArr.firstIndex(of: uwImage) {
            browser.initializePageIndex(uwIndex)
            self.present(browser, animated: true, completion: nil)
        }
    }
}

extension ContentVC: CKeyViewVCellDelegate {
    func keyViewClick(_ data: ChosenList?, _ cell: CKeyViewVCell) {
        guard let uwData = data else {
            return
        }
        let faEvent  = FaEvent.click_play.rawValue
        let faAction = "article_detail_video"
        let faLabel = "\(self.newsTitle)_\(self.newsID)_主影音_文章內頁"
        US.setAnalyticsLogEnvent(event: faEvent, action: faAction, label: faLabel)
        let videoId = uwData.ID
        VideoIDPlayerManager.shard.installOutLinePlayer(cell.keyView, videoID: videoId, completion: { [weak self] player in
            self?.player = player
        })
    }
}

extension ContentVC: CImageCellDelegate {
    func imageClick(_ image: String?) {
        guard let uwImage = image else {
            return
        }
        var pageIndex = 0
        for (index, value) in imgArr.enumerated() {
            if value == image {
                pageIndex = index
                break
            }
        }
        let browser = SKPhotoBrowser(photos: (skImgArr), initialPageIndex: pageIndex)
        if let uwIndex = imgArr.firstIndex(of: uwImage) {
            browser.initializePageIndex(uwIndex)
            self.present(browser, animated: true, completion: nil)
        }
    }
}

extension ContentVC: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        Util.shared.openSafari(URL, self)
        return false
    }
}

extension ContentVC: CTextCellDelegate {
    func urlClick(_ str: String) {
        if let url = URL(string: str) {
            Util.shared.openSafari(url, self)
        }
    }
}

extension ContentVC: BottomShareViewProtocol {
    
    func shareBtnClick() {
        
//        let shortUrl = "https://bit.ly/3QUIuMe"
//        let shareString = "這則國際新聞非看不可\n\n\(self.newsTitle)\n\(self.shareUrl)\n\n最專業的國際新聞，都在TVBS國際+APP\n\(shortUrl)"
        
//        let activity = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
//        self.present(activity, animated: true, completion: nil)
//        
//        //FA
//        let shareFa = "\(self.newsTitle)_\(self.newsID)_文章內頁"
//        US.setShareAnalyticsLogEnvent(contentType: shareFa)
    }

}

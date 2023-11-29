//
//  VideoContentVC.swift
//  videoCollection
//
//  Created by Woody on 2022/4/12.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit
import SnapKit
import CocoaLumberjack


class VideoContentVC: BaseVC {
    enum FromState {
        case apiUrl(String)
        case item(VideoItemContent)
        case initially
        
        var item: VideoItemContent? {
            if case let FromState.item(item) = self {
                return item
            }
            return nil
        }
    }
    
    private var fromState: FromState = .initially {
        didSet {
            if case FromState.item = fromState {
                configureContent()
            }
        }
    }
    
    private lazy var errorView: ApiStatusView = {
        let view = ApiStatusView()
        view.isHidden = true
        view.delegate = self
        return view
    }()
        
    private var item: VideoItemContent? {
        return fromState.item
    }
    
    private let contentView: VideoContentView = VideoContentView()
    
    private weak var player: VideoIDPlayer?
    
    convenience init(_ videoContent: VideoItemContent) {
        self.init(nibName: nil, bundle: nil)
        self.fromState = .item(videoContent)
        self.hidesBottomBarWhenPushed = true
    }
    
    convenience init(_ apiUrl: String) {
        self.init(nibName: nil, bundle: nil)
        self.fromState = .apiUrl(apiUrl)
        self.hidesBottomBarWhenPushed = true
    }
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeNotifactionObsever()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confugureUI()
        configureNavigationBar()
        setAction()
        addNotifactionObsever()
        loadDataIfNeed()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        US.pushShowScreen()
    }
    
    private func confugureUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(errorView)
        view.addSubview(contentView)
        
        contentView.isHidden = true
        let defaultHeight: CGFloat = 45
        let topHeight = UIApplication.shared.windows.first?.safeAreaInsets.top ?? defaultHeight
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview().offset(-topHeight/2)
        }
        
        errorView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
    }
    
    private func configureContent() {
        guard let item = item else { return }
        updateDisplay(true)
        configuring(item)
    }
    
    private func configureNavigationBar() {
        self.navigationItem.hidesBackButton = true
        let btn = UIButton.customBtnForBarButtonItem("left", "", "icon_back")
        btn.addTarget(self, action: #selector(customBackItemClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
        self.navigationItem.title = nil
    }
    
    private func configuring(_ itemContent: VideoItemContent) {
        contentView.configureItem(itemContent)
    }

    private func setAction() {
        
        contentView.playButton.addTarget(self, action: #selector(playViedeo), for: .touchUpInside)
        
        contentView.favoriteIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(favoriteAction)))
    }
    
    private func addNotifactionObsever() {
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("fontChanged"), object: nil, queue: nil) { [weak self] (notification) in
            self?.contentView.adjustLableFont()
        }
    }
    
    private func removeNotifactionObsever() {
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("fontChanged"), object: nil)
    }
    
    func removePlayer() {
        player?.pauseVideo()
    }
    
}

extension VideoContentVC {
    
    private func loadDataIfNeed() {
        guard case let FromState.apiUrl(apiUrl) = fromState else {
            configureContent()
            return
        }
        loadData(apiUrl)
    }
    
    private func loadData(_ apiUrl: String) {
        self.showHUD()
        SingleVideoItemM.getSingleVideo(apiUrl: apiUrl) { [weak self] result in
            switch result {
            case .success(let item):
                self?.fromState = .item(item)
            case .failure(let eror):
                self?.errorView.configureWithData(eror.type)
                self?.updateDisplay(false)
            }
            self?.hiddenHUD()
        }
    }
    
    private func updateDisplay(_ hasItemContent: Bool) {
        contentView.isHidden = !hasItemContent
        errorView.isHidden = hasItemContent
    }
}


extension VideoContentVC {
    
    @objc private func customBackItemClick() {
        guard !self.isModal else {
            self.dismiss(animated: false, completion: nil)
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func playViedeo() {
        
        guard let videoId = item?.videoID else { return }
        VideoIDPlayerManager.shard.installOutLinePlayer(contentView.imageView, videoID: videoId, completion: { [weak self] player in
            self?.player = player
        })
        
        US.pushVideoPlay(videoId)
        
    }
    
    @objc private func favoriteAction() {
        guard let item = item,
              let id = item.videoID else {  return }
        if item.isKeeping {
            cancelFavorite(id)
            US.addToast(view, "取消收藏成功", .center)
        } else {
            addFavorite(item)
            US.addToast(view, "收藏成功", .center)
            // APP- 906 [國際+][iOS]影片推播FA
            // FA
            US.pushVideoCollect(id)
        }
    }
    
    private func cancelFavorite(_ id: String) {
        contentView.adjustFavoriteIcon(false)
        DBS.delFavoriteWithVideoId(id)
    }
    
    private func addFavorite(_ itemContent: VideoItemContent) {
        contentView.adjustFavoriteIcon(true)
        DBS.addFavoriteInVideoItem(itemContent)
    }
    
}

// MARK: ApiStatusViewDelegate
extension VideoContentVC: ApiStatusViewDelegate {
    
    func reloadLblClick() {
        loadDataIfNeed()
    }
    
}

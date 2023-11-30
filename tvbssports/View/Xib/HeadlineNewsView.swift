//
//  HospitalAppointmentView.swift
//  healthmvp
//
//  Created by darrenChiang on 2021/7/29.
//  Copyright © 2021 Eddie. All rights reserved.
//

import UIKit
//import XCDYouTubeKit

class HeadlineNewsView: UIView {
    
    @IBOutlet var listView: UIView!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var blackMaskView: UIView!
    fileprivate let smallCell = "HeadlineNewsSmallCell"
    fileprivate let bigCell   = "HeadlineNewsBigCell"
    @IBOutlet var titleLabel: UILabel!
    
    var headlineNewsList:[HeadlineNews]? {
        didSet{
            self.tableView.reloadData()
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
        initTableView()
    }
    
    func initView() {
        listView.layer.cornerRadius = 10
        listView.layer.masksToBounds = true
        
        buttonView.layer.cornerRadius = 10
        buttonView.layer.masksToBounds = true
        
        let month = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        titleLabel.text = "\(month)/\(day) 國際頭條TOP5"
    }
    
    func initTableView() {
        self.tableView.dataSource      = self
        self.tableView.delegate        = self
        self.tableView?.separatorStyle = .none
        self.tableView?.register(UINib(nibName: "HeadlineNewsBigCell", bundle: nil), forCellReuseIdentifier: "HeadlineNewsBigCell")
        self.tableView?.register(UINib(nibName: "HeadlineNewsSmallCell", bundle: nil), forCellReuseIdentifier: "HeadlineNewsSmallCell")
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func shareAction(_ sender: Any) {

//        var item = self.headlineNewsList?.map({ (headline) -> Any in
//            guard let videoID = headline.video_id else {
//                return URL(string: headline.api_url ?? "")!
//            }
//            return URL(string:"https://www.youtube.com/watch?v=\(videoID)")!
//        })
        
        var item = self.headlineNewsList?.map({ (headline) -> String in
            guard let videoID = headline.video_id else {
                return headline.api_url ?? ""
            }
            return "https://www.youtube.com/watch?v=\(videoID)"
        })
    
    
        item?.insert(titleLabel.text ?? "國際頭條", at: 0)

        guard let actiivityitem = item else {
            return
        }
        
        let activity = UIActivityViewController(activityItems: actiivityitem, applicationActivities: nil)
        UIApplication.topViewController()?.topMostViewController().present(activity, animated: true, completion: nil)
    }
    
    
    //MARK: static func
    /**
        將HeadlineNewsView:，呈現在想顯示的view上面
     
     - Parameter view: HeadlineNewsView:.
     - Parameter topview: SuperView，要呈現的父View.
     
     ### Usage Example: ###
     let view = HeadlineNewsView:.fromNib()
     HospitalAppointmentView.presentView(view: view, topview: superView)
    */
    static func presentView( view:HeadlineNewsView , topview:UIView ) {
        view.frame = UIScreen.main.bounds
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        currentWindow?.addSubview(view)
        
        
        // UPDATE for iOS13 and above 有可能要試一下之後要改
        //UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.addSubview(myView)
        HeadlineNewsView.fadeInOnLayView(topview: topview, overlayView: view)
    }

    /**
        動畫漸層呈現View
    */
    static func fadeInOnLayView(topview:UIView , overlayView:UIView) {
        
        guard let popView = overlayView as? HeadlineNewsView else {
            return
        }
        let mask = popView.blackMaskView
        let list = popView.listView
        let button = popView.buttonView

        mask?.alpha = 0.0
        list?.alpha = 0.0
        button?.alpha = 0.0
        
        UIView.animate(withDuration: 0.15) {
            mask?.alpha = 0.5
            list?.alpha = 1.0
            button?.alpha = 1.0
        } completion: { (Bool) in
            
        }
    }
    
    /**
        動畫漸層關閉View
    */
    static func fadeOutOnLayView(topview:UIView , overlayView:UIView) {
        
    }

//end
}

extension HeadlineNewsView: UITableViewDataSource, UITableViewDelegate  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.headlineNewsList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let data = self.headlineNewsList?[safe:indexPath.row] else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: bigCell , for: indexPath) as! HeadlineNewsBigCell
            cell.configureWithData(data: data)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: smallCell , for: indexPath) as! HeadlineNewsSmallCell
            cell.configureWithData(data: data)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let data = self.headlineNewsList?[safe:indexPath.row] else {
            return
        }
        
        /**
          有video_id表示文章內容為影音，直接播放
          沒有就表示是文字文章，開啟文章內頁
        */
        let top =  UIApplication.topViewController()
        guard let videoID = data.video_id else {
            let vc = ContentVC(data.api_url ?? "", data.name ?? "")
            let modelNav = UINavigationController(rootViewController: vc)
            modelNav.modalPresentationStyle = .fullScreen
            modelNav.hidesBottomBarWhenPushed = true
            modelNav.navigationBar.isTranslucent = false
            top?.topMostViewController().present(modelNav, animated: true, completion: nil) 
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsImageCellProtocol else { return }
        
        VideoIDPlayerManager.shard.installOutLinePlayer(cell.newsImageView, videoID: videoID) { _ in }
//        XCDYouTubeClient.default().getVideoWithIdentifier(data.video_id) { (video, error) in
//            guard error == nil else {
//                return
//            }
//           // AVPlayerViewControllerManager.shared.lowQualityMode =
//            AVPlayerViewControllerManager.shared.video = video
//            top?.topMostViewController().present(AVPlayerViewControllerManager.shared.controller, animated: true) {
//                AVPlayerViewControllerManager.shared.controller.player?.play()
//            }
//        }
        
    }
    
}



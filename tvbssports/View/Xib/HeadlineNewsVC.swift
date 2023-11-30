//
//  HeadlineNewsVC.swift
//  videoCollection
//
//  Created by darren on 2021/12/13.
//  Copyright © 2021 Eddie. All rights reserved.
//

import UIKit
import CocoaLumberjack


class HeadlineNewsVC: BaseVC {

    @IBOutlet var listView: UIView!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    fileprivate let smallCell = "HeadlineNewsSmallCell"
    fileprivate let bigCell   = "HeadlineNewsBigCell"
    
    let month = Calendar.current.component(.month, from: Date())
    let day = Calendar.current.component(.day, from: Date())
    
    var headlineNewsList:[HeadlineNews]?
    
    private weak var player: VideoIDPlayer?
    
    deinit {
       print("\(type(of: self)) is Deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initTableView()
        US.setAnalyticsLogEnvent(event: "show_screen", action: "Cover Page", label: "開啟_蓋版頁")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func initView() {
        listView.layer.cornerRadius = 10
        listView.layer.masksToBounds = true
        
        buttonView.layer.cornerRadius = 10
        buttonView.layer.masksToBounds = true
        
        titleLabel.text = "\(month)/\(day) 國際頭條TOP5"
    }
    
    func initTableView() {
        self.tableView.dataSource      = self
        self.tableView.delegate        = self
        self.tableView?.separatorStyle = .none
        self.tableView?.register(UINib(nibName: "HeadlineNewsBigCell", bundle: nil), forCellReuseIdentifier: "HeadlineNewsBigCell")
        self.tableView?.register(UINib(nibName: "HeadlineNewsSmallCell", bundle: nil), forCellReuseIdentifier: "HeadlineNewsSmallCell")
        
        guard let _ = headlineNewsList else {
            return
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        SM.headlineNewsVC = nil
        
        // APP- 839 點推播開啟［每日必看頭條］後，點影片播放，旋轉沒有切換成全畫面
        view.removeFromSuperview()
        removeFromParent()
    }
    
    @IBAction func shareAction(_ sender: Any) {

        let item = self.headlineNewsList?.enumerated().map({ (index ,headline)  -> String in
            
            /** 第ㄧ筆  加頭條 */
            let subject = titleLabel.text ?? "國際頭條"
            let subjectWithPadding = "\(subject)\n\n"
            let firsttitle = index == 0 ? subjectWithPadding  : ""
             
            /** 判斷文章或是影片連結 */
            guard let shareUrl = headline.share_url else {
                return "\(firsttitle)\(headline.title ?? "")\n \n\n"
            }
            return "\(firsttitle)\(headline.title ?? "")\n \(shareUrl)\n\n"
        })
        
        guard let actiivityitem = item else {
            return
        }
        
        let string = actiivityitem.joined(separator: "")
        
        let activity = UIActivityViewController(activityItems: [string], applicationActivities: nil)
        
        self.present(activity, animated: true, completion: nil)
        
        //FA
        US.setShareAnalyticsLogEnvent(contentType: "\(month)/\(day)_每日必看_蓋版頁")
    }
    
    func playVideo(video_id:String, _ view: UIView)  {
        VideoIDPlayerManager.shard.installOutLinePlayer(view, videoID: video_id, completion: { [weak self] player in
            self?.player = player
        })
        
    }
    
    func closePlayerVC() {
        player?.pauseVideo()
    }
}

extension HeadlineNewsVC: UITableViewDataSource, UITableViewDelegate  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.headlineNewsList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let data = self.headlineNewsList?[safe:indexPath.row] , let list = self.headlineNewsList else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: bigCell , for: indexPath) as! HeadlineNewsBigCell
            cell.configureWithData(data: data)
            return cell
        default:
            let lastIndex = list.count - 1
            let showLine = indexPath.row == lastIndex  ? true : false
            let cell = tableView.dequeueReusableCell(withIdentifier: smallCell , for: indexPath) as! HeadlineNewsSmallCell
            cell.configureWithData(data: data , showLine: showLine)
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
        guard let video_id = data.video_id else {
            let vc = ContentVC(data.api_url ?? "", data.name ?? "")
            let modelNav = UINavigationController(rootViewController: vc)
            modelNav.modalPresentationStyle = .fullScreen
            modelNav.hidesBottomBarWhenPushed = true
            modelNav.navigationBar.isTranslucent = false
            UINavigationBar.appearance().barTintColor = .black
            UINavigationBar.appearance().backgroundColor = .backgroundColor
            self.present(modelNav, animated: true, completion: nil)
            
            
            //FA
            let title = data.title ?? ""
            let news_id = data.news_id ?? ""
            US.setAnalyticsLogEnvent(event: "click_article", action: "cover_article", label: "\(String(describing: title))_\(String(describing: news_id))_文章_蓋版頁")
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsImageCellProtocol else { return }
        
        
        self.playVideo(video_id: video_id, cell.newsImageView)
    }
    
}

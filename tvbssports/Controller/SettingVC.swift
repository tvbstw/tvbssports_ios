//
//  SettingVC.swift
//  videoCollection
//
//  Created by leon on 2021/1/27.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit
import CocoaLumberjack
import StepSlider

class SettingVC: UIViewController {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var sliderView: StepSlider!
    @IBOutlet weak var tableView: UITableView!
//    fileprivate let videoCell = "videoCell"
    fileprivate let sArticleListCell = "sArticleListCell"
    fileprivate let sTitleCell = "sTitleCell"
    fileprivate let sContentCell = "sContentCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "字級大小"
        self.view.backgroundColor = UIColor.backgroundColor
        setNavigation()
        setSlider()
        setTableView()
        addNotification()
        US.setAnalyticsLogEnvent(event: "show_screen", action: "Setting fontsize", label: "開啟_字級頁")
    }
    
    deinit {
        removeNotification()
    }
    
    func addNotification() {
        weak var weakSelf = self
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("fontChanged"), object: nil, queue: nil) { (notification) in
            weakSelf?.tableView?.reloadData()
        }
    }
    
    func removeNotification() {
        NOTIFICATION_CENTER.removeObserver(self, name: Notification.Name("fontChanged"), object: nil)
    }
    
    func setNavigation() {
        self.navigationItem.title = "字級大小"
        self.navigationController?.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor:UIColor.textColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 19.0, weight: .medium)]
        self.navigationItem.hidesBackButton = true
        let btn = UIButton.customBtnForBarButtonItem("left", "", "icon_back")
        btn.addTarget(self, action: #selector(customBackItemClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    @objc func customBackItemClick() {
        let fontSize = USER_DEFAULT.integer(forKey: "fontSize")
        let faEvent  = "click_fontsize"
        var faAction = ""
        let faLabel = "字級_\(FONTSIZE_LABELS[fontSize])_字級頁"
        switch fontSize {
            case 0:
                faAction = "setting_fontsize_small"
            case 1:
                faAction = "setting_fontsize_middle"
            case 2:
                faAction = "setting_fontsize_big"
            case 3:
                faAction = "setting_fontsize_max"
            default:break
        }
        US.setAnalyticsLogEnvent(event: faEvent, action: faAction, label: faLabel)        
        self.navigationController?.popViewController(animated: true)
    }
    
    func setSlider() {
        sliderView.maxCount = 4
        sliderView.trackHeight = 10
        /*
        sliderView.trackCircleRadius = 10
        sliderView.sliderCircleRadius = 15
        sliderView.trackColor = UIColor.gray
        sliderView.sliderCircleColor = UIColor.orange
        sliderView.tintColor = UIColor.orange
        */
        
        sliderView.trackCircleRadius = 5
        sliderView.sliderCircleRadius = 10
        sliderView.trackColor = UIColor.gray
        sliderView.sliderCircleColor = UIColor.videoTimeColor
        sliderView.tintColor = UIColor.videoTimeColor
        sliderView.sliderCircleImage = UIImage(named: "text_level_circle")
        
        
        sliderView.labelOffset = 20
        sliderView.labels = FONTSIZE_LABELS
        sliderView.labelColor = SETTING_LABEL_COLOR
        sliderView.labelFont = UIFont.systemFont(ofSize: 16.0)
        sliderView.index = UInt(USER_DEFAULT.integer(forKey: "fontSize"))
//        sliderView.backgroundColor = UIColor.RGB(51, 51, 51)
    }
    
    func setTableView() {
//        tableView?.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: videoCell)
        tableView?.register(UINib(nibName: "SArticleListCell", bundle: nil), forCellReuseIdentifier: sArticleListCell)
        tableView?.register(UINib(nibName: "STitleCell", bundle: nil), forCellReuseIdentifier: sTitleCell)
        tableView?.register(UINib(nibName: "SContentCell", bundle: nil), forCellReuseIdentifier: sContentCell)
        
        tableView?.tableFooterView = UIView(frame: .zero)
        tableView?.backgroundColor = UIColor.backgroundColor
        tableView?.separatorStyle = .none
        tableView.reloadData()
    }
    
    @IBAction func valueChanged(_ sender: StepSlider) {
        USER_DEFAULT.set(sender.index, forKey: "fontSize")
        USER_DEFAULT.synchronize()
        NOTIFICATION_CENTER.post(name: NSNotification.Name("fontChanged"), object: nil)
    }
    
}

extension SettingVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: videoCell, for: indexPath) as! VideoCell
//        cell.fromVC = self
//        let chosenList = ChosenList()
//        chosenList.videoItem = VideoItemContent.init(JSON: ["video_id":"","title":"【ON AIR】TVBS 56頻道 國際新聞 同步直播多元節目 隨選隨看","image":"","publish":"2021/01/10 12:12","en_name":"","live":""])
//        cell.configureWithSample(chosenList)
//        cell.backgroundColor = SETTING_COLOR
//        return cell
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: sTitleCell, for: indexPath) as! STitleCell
            cell.titleLbl.text = "分類列表顯示範例"
            cell.backgroundColor = UIColor.backgroundColor
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: sArticleListCell, for: indexPath) as! SArticleListCell

            cell.configureWithData()
            cell.backgroundColor = UIColor.backgroundColor
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: sTitleCell, for: indexPath) as! STitleCell
            cell.titleLbl.text = "文章顯示範例"
            cell.backgroundColor = UIColor.backgroundColor
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: sContentCell, for: indexPath) as! SContentCell

            cell.configureWithData()
            cell.backgroundColor = UIColor.backgroundColor
            return cell
            
        default:
            return UITableViewCell()
        }

            
    }
}

extension SettingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 200
        }else{
            return UITableView.automaticDimension
        }
        
        
        
//        return 100
    }
}

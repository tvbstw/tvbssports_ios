//
//  ADBigCardCell.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/26.
//  Copyright © 2023 Eddie. All rights reserved.
//

import UIKit
import CocoaLumberjack
import SnapKit
import Firebase
//import GoogleMobileAds

class ADBigCardCell: UITableViewCell {
    @IBOutlet weak var adBaseView: UIView!
    @IBOutlet weak var adTopExcisionView: UIView!
    @IBOutlet weak var adSponsoredLbl: UILabel!
    @IBOutlet weak var adTitleLbl: UILabel!
//    @IBOutlet weak var adMediaView: GADMediaView!
    @IBOutlet weak var adDescLbl: UILabel!
    @IBOutlet weak var adIconLbl: UILabel!
    @IBOutlet weak var adBtn: UIView!
    @IBOutlet weak var adBtnLbl: UILabel!
    @IBOutlet weak var adSponsorLbl: UILabel!
    @IBOutlet weak var adSparatorView: UIView!
    @IBOutlet weak var adBottomExcisionView: UIView!
    @IBOutlet weak var adBaseViewbottom: NSLayoutConstraint!
    
    fileprivate var menuID: String  = ""
    fileprivate var adCode: String  = ""
    fileprivate var adName: String  = ""
    fileprivate var adIndex: String = ""
    fileprivate var cEngNm: String = ""
    fileprivate var cNm: String    = ""
    fileprivate var indexPath: IndexPath = IndexPath()
//    fileprivate var adLoader: GADAdLoader!
    fileprivate var superVC: UIViewController?
    
    #if !(targetEnvironment(simulator))
//    fileprivate var nativeAdArr = [(type: String, index: Int, data: GADNativeAd)]()    //儲存廣告laod過的資料
    #endif
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.adBtn.layer.cornerRadius = 15.0
        self.adBtn.layer.masksToBounds = true
        
        #if !(targetEnvironment(simulator))
        self.hideObject()
        self.addNotificaiton()
        #else
        self.showObject()
        #endif
    }
    
//    func configureWithData(_ data: ChosenList, _ indexPath: IndexPath, _ superVC:UIViewController?, _ nativeAD: GADNativeAd?) {
//        self.menuID = data.menuID
//        self.adCode = data.adCode
//        self.adName = data.adName
//        self.adIndex = data.adIndex
//        self.indexPath = indexPath
//        self.cEngNm = data.categoryEngNM
//        self.cNm = data.categoryNM
//        self.adSparatorView.isHidden = (data.adFrom == .content) ? true : false
//        self.adBaseViewbottom.constant = (data.adFrom == .content) ? 0 : 6.5
//        self.superVC = superVC
//        //debugPrint("self.indexPath.row:\(self.indexPath.row)")
//        //debugPrint("self.loadedRowArr.count:\(self.loadedRowArr.count)")
//        //第一次進來打api取值
//        //if !self.loadedRowArr.contains(self.indexPath.row) {
//        if let uwNativeAD = nativeAD {
//            self.showObject()
//            self.adBaseView.nativeAd = nativeAD
//            //nativeAD.delegate = self
//            self.adMediaView.mediaContent = uwNativeAD.mediaContent
//            //if uwNativeAD.mediaContent.hasVideoContent {
//                //nativeAD.mediaContent.videoController.delegate = self
//            //}
//            self.adTitleLbl.text = Util.shared.checkNil(uwNativeAD.headline)
//            self.adDescLbl.text = Util.shared.checkNil(uwNativeAD.body)
//            self.adSponsorLbl.text = Util.shared.checkNil(uwNativeAD.advertiser)
//            self.adBtnLbl.text = Util.shared.checkNil(uwNativeAD.callToAction)
//        } else {
//            NOTIFICATION_CENTER.post(name: NSNotification.Name("reloadADCardCellHeight"), object: nil)
//        }
//    }
    
    func addNotificaiton() {
        #if !(targetEnvironment(simulator))
        NOTIFICATION_CENTER.addObserver(forName: Notification.Name("resetRowArr"), object: nil, queue: nil) { (notificaiton) in
            guard let userInfo = notificaiton.userInfo, let menuID = userInfo["menuID"] as? String else {
                return
            }
            if menuID == self.menuID {
                //SM.adArr[self.menuID]?.hiddenIndexArr.removeAll()
                //SM.adArr[self.menuID]?.loadedIndexArr.removeAll()
                //SM.adArr[self.menuID]?.hiddenIndexPathArr.removeAll()
                //self.hiddenRowArr.removeAll()
                //self.loadedRowArr.removeAll()
//                self.nativeAdArr.removeAll()
            }
        }
        #endif
    }
    
    func showObject() {
        self.adBaseView.isHidden   = false
        self.adSponsorLbl.isHidden = false
        self.adTitleLbl.isHidden   = false
//        self.adMediaView.isHidden  = false
        self.adDescLbl.isHidden    = false
        self.adIconLbl.isHidden    = false
        self.adSponsorLbl.isHidden = false
        self.adBtn.isHidden = false
    }
    
    func hideObject() {
//        self.adBaseView.isHidden   = true
//        self.adSponsorLbl.isHidden = true
//        self.adTitleLbl.isHidden   = true
//        self.adMediaView.isHidden  = true
//        self.adDescLbl.isHidden    = true
//        self.adIconLbl.isHidden    = true
//        self.adSponsorLbl.isHidden = true
//        self.adBtn.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.restoreStatus()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.restoreStatus()
    }
    
    func restoreStatus() {
        self.adTopExcisionView.backgroundColor = UIColor.RGB(207, 207, 207)
        self.adBottomExcisionView.backgroundColor = UIColor.RGB(207, 207, 207)
        self.adSparatorView.backgroundColor = UIColor.RGBA(223, 225, 225, 0.2)
        self.adBtn.backgroundColor = UIColor.RGB(212, 25, 4)
        self.adIconLbl.backgroundColor = UIColor.RGB(224, 224, 224)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

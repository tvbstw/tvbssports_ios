//
//  ADBannerCell.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/26.
//  Copyright © 2023 Eddie. All rights reserved.
//

class ADBannerCell: UITableViewCell {
//    @IBOutlet weak var adBaseView: GADNativeAdView!
    @IBOutlet weak var adTopExcisionView: UIView!
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
    
//    var nativeAd: GADNativeAd? {
//        get {
//            nativeAdParameter
//        }
//        set {
//            nativeAdParameter = newValue
//        }
//    }
//
//    var index: String = "" {
//        didSet {
//            guard let nativeAd = nativeAdParameter else {
//                DDLogError("index:\(index) nativeAd is nil")
//                return
//            }
//
//            adBaseView.nativeAd      = nativeAd
//            adMediaView.mediaContent = nativeAd.mediaContent
//            adTitleLbl.text          = nativeAd.headline
//            adDescLbl.text           = nativeAd.body
//            adSponsorLbl.text        = nativeAd.advertiser
//            adBtnLbl.text            = nativeAd.callToAction
//        }
//    }
//
//    private var nativeAdParameter: GADNativeAd?
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        //DDLogInfo("prepareForReuse")
//    }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setUI("")
//    }
//
//    private func setUI(_ typeString: String) {
//        self.adBtn.layer.cornerRadius = 15.0
//        self.adBtn.layer.masksToBounds = true
//        self.adIconLbl.layer.borderColor = UIColor.RGB(128, 128, 128).cgColor
//        self.adIconLbl.layer.borderWidth = 0.5
//        self.adSparatorView.isHidden = (typeString == "line") ? true : false
//        self.adBaseViewbottom.constant = (typeString == "line") ? 0 : 6.5
//        self.adBaseView.backgroundColor = ADCELL_COLOR
//        self.adBtn.backgroundColor = UIColor.RGB(219, 219, 219)
//        self.adBtn.layer.cornerRadius = 3
//        self.adTitleLbl.font = UIFont(name: "PingFangTC-Medium", size: 17)
//        self.adTitleLbl.textColor = UIColor.RGB(0, 0, 0)
//        self.adDescLbl.font = UIFont(name: "PingFangTC-Regular", size: 14)
//        self.adDescLbl.textColor = MAIN_GRAY_COLOR
//        self.adSponsorLbl.font = UIFont(name: "PingFangTC-Medium", size: 12)
//        self.adSponsorLbl.textColor = SPONSOR_TITLE_COLOR
//        self.adBtnLbl.font = UIFont(name: "PingFangTC-Medium", size: 14)
//        self.adBtnLbl.textColor = LINK_TITLE_COLOR
//        self.isUserInteractionEnabled = true
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        self.restoreStatus()
//    }
//
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        super.setHighlighted(highlighted, animated: animated)
//        self.restoreStatus()
//    }
//
//    private func restoreStatus() {
//        self.adTopExcisionView.backgroundColor = UIColor.RGB(207, 207, 207)
//        self.adBottomExcisionView.backgroundColor = UIColor.RGB(207, 207, 207)
//        self.adSparatorView.backgroundColor = UIColor.RGBA(223, 225, 225, 0.2)
//        self.adIconLbl.backgroundColor = UIColor.RGB(224, 224, 224)
//    }
//
}

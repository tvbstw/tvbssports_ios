//
//  Util.swift
//  youtubeCollection
//
//  Created by leon on 2020/12/17.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import Kingfisher
import KingfisherWebP
import SafariServices
import Toast_Swift
import CocoaLumberjack
import Firebase
import FirebaseCrashlytics

final class Util: NSObject {
    static let shared = Util()
    
    private override init(){}
    
    func loadingImages() -> [UIImage] {
        var imageArr = [UIImage]()
        for i in 1...12 {
            let str = "loading_" + String(i)
            imageArr.append(UIImage(named: str)!)
        }
        return imageArr
    }
    
    func openSafari(_ url: URL, _ controller: UIViewController) {
        let safariVC = SFSafariViewController(url: url)
        if #available(iOS 10.0, *) {
            safariVC.preferredBarTintColor = .white
        }
        controller.present(safariVC, animated: true, completion: nil)
        
    }
    /**
     Check String nil.
     - Parameter string: string optional.
     */
    func checkNil(_ string: String?) -> String {
        if let str = string {
            return str
        } else {
            return ""
        }
    }
    
    /**
     API Path.
     - Parameter menuLink: api path.
     - Parameter paramters: nextPage.
     */
    func apiPath(_ menuLink: String, _ paramters: String?) -> String {
        var path = "\(API_DOMAIN)\(menuLink)/"
        if let param = paramters {
            if !param.isEmpty {
                path = "\(path)\(param)"
            }
        }
        return path
    }

    
    func swipeCellButtons(_ tableView: UITableView, _ indexPath: IndexPath) -> UIImage {
        let frame = tableView.rectForRow(at: indexPath)
        
        let spearatorView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: tableView.frame.size.height))
        spearatorView.backgroundColor = UIColor.backgroundColor

        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: (frame.size.height - 6.5)))
        backView.backgroundColor = UIColor.backgroundColor
        backView.layer.opacity = 1
        spearatorView.addSubview(backView)
        
        let myImage = UIImageView(frame: CGRect(x: 25, y: frame.size.height/2-18, width: 26, height: 34))
        myImage.image = UIImage(named: "delete_w")!
        spearatorView.addSubview(myImage)
        
        let imgSize: CGSize = tableView.frame.size
        UIGraphicsBeginImageContextWithOptions(imgSize, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        spearatorView.layer.render(in: context!)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /**
     Show toast message.
     - Parameter view: superView.
     */
    func addToast(_ view: UIView, _ messgae: String, _ position:ToastPosition = .bottom) {
        var style = ToastStyle()
        style.messageColor = .selectColor
        view.makeToast(messgae, duration: 1.0, position: position, title: nil, image: nil, style: style, completion: nil)
    }
    
    // MARK: -FA
    func setAnalyticsLogEnvent(event:String, action:String , label:String){
        let params = ["action":action, "label":label]
        DDLogInfo("Event:\(event), Action:\(action), Label:\(label)")
        Analytics.logEvent(event, parameters: params)
    }

    // MARK: -FA search
    func setSearchAnalyticsLogEnvent(searchItem:String){
        let params = [AnalyticsParameterSearchTerm:searchItem]
        DDLogInfo("Event:\(AnalyticsEventSearch), SearchTerm:\(searchItem)")
        Analytics.logEvent(AnalyticsEventSearch, parameters: params)
    }
    
    // MARK: -FA share
    func setShareAnalyticsLogEnvent(contentType:String){
        let params = [AnalyticsParameterContentType:contentType]
        DDLogInfo("Event:\(AnalyticsEventShare), ContentType:\(contentType)")
        Analytics.logEvent(AnalyticsEventShare, parameters: params)
    }
    
    /**
       Download image.
       - Parameter imageView: UIImageView
       - Parameter imageUrl:  String.
       */
    func setImage(_ imageView: UIImageView!, _ imageUrl: String, _ type: String = "") {

        var imageName = "img_default"
        switch type {
            case "productL":
                imageName = "img_default_1_1"
            case "shake":
                imageName = "img_default"
            case "player":
                imageName = "player_member"
            case "content":
                imageName = "img_default_16_9"
            case "headLine":
                imageName = "img_default_5_6"
            case "category":
                imageName = "img_default_1_1"
            case "picture":
                imageName = "img_default_5_6"
            default:break
        }
          
        imageView.kf.setImage(with: URL(string:imageUrl), placeholder: UIImage(named:imageName), options: [.transition(ImageTransition.fade(IMAGE_FADE_SEC)), .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)], progressBlock: nil, completionHandler: nil)
      }
    
    /**
     Canel image.
     - Parameter imageView: UIImageView
     */
    func canelImage(_ imageView:UIImageView!) {
        imageView.kf.cancelDownloadTask()
    }
    
    func dataTransString(_ responseData:Data?) -> String {
        var text = ""
        if let data = responseData, let utf8Text = String(data: data, encoding: .utf8) {
            text = utf8Text
        }
        return text
    }
    
}

//
//  ContentM.swift
//  videoCollection
//
//  Created by TVBS on 2021/7/2.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Reachability
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

struct Content: Mappable {
    var type: String?
    var data: ContentData?
    
    init?(map: Map) {}
    mutating func mapping(map: Map) {
        type <- map["type"]
        data <- map["data"]
    }
}

struct ContentData: Mappable {
    var articleID: String?
    var publish: String?
    var title: String?
    var userEcho: String?
    var image: String?
    var videoID: String?
    var videoImg: String?
    var nativeContentArr: [NativeContent]?
    var extensionArr: [ArticleListContent]?
    var categoryID: String?
    var categoryLabel: String?
    var categoryName: String?
    var imgList: [String]?
    var shareUrl: String?
    
    init?(map: Map) {}
    mutating func mapping(map: Map) {
        articleID <- map["article_id"]
        publish <- map["publish"]
        title <- map["title"]
        userEcho <- map["user_echo"]
        image <- map["image"]
        videoID <- map["video_id"]
        videoImg <- map["video_img"]
        nativeContentArr <- map["content"]
        extensionArr <- map["extension"]
        categoryID <- map["category_id"]
        categoryLabel <- map["category_label"]
        categoryName <- map["category_name"]
        imgList <- map["img_list"]
        shareUrl <- map["share_url"]
    }
}

struct NativeContent: Mappable {
    var type: String?
    var value: String?
    var alt: String?
    
    init?(map: Map) {}
    mutating func mapping(map: Map) {
        type <- map["type"]
        value <- map["value"]
        alt <- map["alt"]
    }
}

class ContentM: NSObject {
    static let shared = ContentM()
    
    func getContent(apiUrl: String, completion: @escaping (_ response: APIResult<Content, APIError>) -> ()) {
        
        let reachability = try! Reachability()
        reachability.whenReachable = { _ in
            guard reachability.connection != .unavailable else {
                return
            }
            AF.request(apiUrl, method: .get, parameters: nil, encoding: URLEncoding.default ,headers: nil).responseObject(completionHandler: { (response:DataResponse<Content, AFError>) in
                  switch response.result {
                  case .success(let responseData):
                      if let statusCode = response.response?.statusCode {
                          if statusCode == 200 {
                            completion(.success(responseData))
                          } else {
                            let statusCode = (String(describing: response.response?.statusCode))
                            DDLogError("get:success - statusCode:\(statusCode)")
                            completion(.failure(E: APIError(type: .error, localDesc: statusCode)))
                          }
                      }
                  case .failure(let error):
                      DDLogError("get:error - statusCode:\(String(describing: response.response?.statusCode)) error:\(error)")
                     completion(.failure(E: APIError(type: .error, localDesc: error.localizedDescription)))
                  }
              })
        }
        reachability.whenUnreachable = { _ in
      
          completion(.failure(E: APIError(type: .unreachable , localDesc: "network unreachable")))
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            DDLogInfo("Unable to start notifier")
        }
        reachability.stopNotifier()
    }
}

//
//  ArticleListM.swift
//  videoCollection
//
//  Created by darrenChiang on 2021/7/1.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Reachability
import Alamofire
import AlamofireObjectMapper
import ObjectMapper


//文章列表
struct ArticleList: Mappable {
    var type: String
    var apiStatusData: [APIStatus]?
    var rotateData:[ArticleListContent]?
    var nextPageData: [NextPage]?
    var newsData:ArticleListContent?
    init?(map: Map) {
        type = (try? map.value("type")) ?? ""
    }
    
    mutating func mapping(map: Map) {
        switch type {
            case "apiStatus":
                apiStatusData      <- map["data"]
            case "rotate":
                rotateData         <- map["data"]
            case "nextPage":
                nextPageData       <- map["data"]
            case "news":
                //示意
                newsData           <- map["data"]
            default:
                break
        }
    }
}

struct ArticleListContent: Mappable {
    var news_id: String?
    var videoID: String?
    var title: String?
    var image: String?
    var publish: String?
    var enName: String?
    var name: String?
    var api_url: String?
    var videoTime: String?
    
    init?(map: Map) {}
    mutating func mapping(map: Map) {
        news_id    <- map["news_id"]
        videoID    <- map["video_id"]
        title      <- map["title"]
        image      <- map["image"]
        publish    <- map["publish"]
        enName     <- map["en_name"]
        name       <- map["name"]
        api_url    <- map["api_url"]
        videoTime <- map["video_time"]
    }
}

class ArticleListM: NSObject {
    static let shared = ArticleListM()
    
    /**
          取得文章列表頁面資料.
          - Parameter apiUrl: String
          - completion : APIResult<[ArticleList], APIError>
    */
    func getArticleListItem(apiUrl: String , completion: @escaping (_ response: APIResult<[ArticleList], APIError>) -> ()) {
        
          let reachability = try! Reachability()
          reachability.whenReachable = { _ in
              guard reachability.connection != .unavailable else {
                  return
              }
            AF.request(apiUrl, method: .get, parameters: nil, encoding: URLEncoding.default ,headers: nil).responseArray(completionHandler: { (response:DataResponse<[ArticleList], AFError>) in
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

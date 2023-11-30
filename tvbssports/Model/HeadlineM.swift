//
//  HeadlineM'.swift
//  videoCollection
//
//  Created by darren on 2021/12/7.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Reachability
import Alamofire
import AlamofireObjectMapper
import ObjectMapper


struct HeadlineNews: Mappable {
    var video_id: String?
    var title: String?
    var image: String?
    var publish: String?
    var en_Name: String?
    var name: String?
    var live: String?
    var api_url: String?
    var news_id:String?
    var video_time:String?
    var share_url: String?
    
    init?(map: Map) {}
    mutating func mapping(map: Map) {
        video_id   <- map["video_id"]
        if video_id == "" {
            video_id = nil
        }
        title      <- map["title"]
        image      <- map["image"]
        publish    <- map["publish"]
        en_Name    <- map["en_name"]
        live       <- map["live"]
        name       <- map["name"]
        news_id    <- map["news_id"]
        api_url    <- map["api_url"]
        video_time <- map["video_time"]
        share_url    <- map["share_url"]
    }
}

class HeadlineM: NSObject {
    static let shared = HeadlineM()
    fileprivate override init() {}
    
    /**
          取得改版頭條新聞.
          - completion : APIResult<[SupertasteSearchDiscountList], APIError>
    */
    func getHeadlineNewsList( completion: @escaping (_ response: APIResult<[HeadlineNews], APIError>) -> ()) {
        
          let reachability = try! Reachability()
          reachability.whenReachable = { _ in
              guard reachability.connection != .unavailable else {
                  return
              }
            AF.request(HEADLINENEWS_API, method: .get, encoding: URLEncoding.default ,headers: nil).responseArray(completionHandler: { (response:DataResponse<[HeadlineNews], AFError>) in
                  switch response.result {
                  case .success(let responseData):
                      if let statusCode = response.response?.statusCode {
                          if statusCode == 200 {
                              guard  responseData.count != 0 else {
                                  completion(.failure(E: APIError(type: .empty, localDesc: "data empty")))
                                  return
                              }
                              completion(.success(responseData))
                          } else {
                            let statusCode = (String(describing: response.response?.statusCode))
                            DDLogError("get:success - statusCode:\(statusCode)")
                            completion(.failure(E: APIError(type: .service, localDesc: statusCode)))
                          }
                      }
                  case .failure(let error):
                      DDLogError("get:error - statusCode:\(String(describing: response.response?.statusCode)) error:\(error)")
                     completion(.failure(E: APIError(type: .error, localDesc: error.localizedDescription)))
                  }
              })
          }
          
          reachability.whenUnreachable = { _ in
              DDLogError("get:unreachable")
            completion(.failure(E: APIError(type: .network, localDesc: "network unreachable")))
          }
          
          do {
              try reachability.startNotifier()
          } catch {
              DDLogInfo("Unable to start notifier")
          }
          reachability.stopNotifier()
      }
 
    
}

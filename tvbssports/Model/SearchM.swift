//
//  SearchM.swift
//  videoCollection
//
//  Created by darren on 2020/12/24.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import CocoaLumberjack
import ObjectMapper
import Reachability



///搜尋
struct SearchItemList: Mappable {
    var data: [VideoItem]?
    var nextPageData: [NextPage]?
    var type: String?
    var count: String
    
    init?(map: Map) {
          type = (try? map.value("type")) ?? ""
          count = (try? map.value("count")) ?? ""
    }
    
    mutating func mapping(map: Map) {
        switch type {
                case "video":
                    data         <- map["data"]
                case "nextPage":
                    nextPageData <- map["data"]
                default:
                    break
            }
        count  <- map["count"]
    }
}

struct VideoItem: Mappable {
    var videoItemContent: VideoItemContent?
    var cellLayout: CellLayout?
    var type: String?

    init?(map: Map) {
        type = (try? map.value("type")) ?? ""
    }
    
    mutating func mapping(map: Map) {
        videoItemContent <- map["data"]
        cellLayout = .video
    }
}

struct VideoItemContent: Mappable {
    var videoID: String?
    var title: String?
    var image: String?
    var publish: String?
    var enName: String?
    var name: String?
    var live: String?
    var videoTime: String?
    var platlistID: String?
    var categoryName:String?
    
    init() {}
    init?(map: Map) {}
    mutating func mapping(map: Map) {
        videoID      <- map["video_id"]
        title        <- map["title"]
        image        <- map["image"]
        publish      <- map["publish"]
        enName       <- map["en_name"]
        name         <- map["name"]
        live         <- map["live"]
        videoTime    <- map["video_time"]
        platlistID   <- map["playlist_id"]
        categoryName <- map["fa_category_name"]
    }
}

extension VideoItemContent {
    var isValidVideoTime: Bool {
        let time = videoTime
        return time == nil ? false : (time != "0:00" && time != "")
    }
    
    var isLive: Bool {
        return live == nil ? false : live == "1"
    }
    
    var isKeeping: Bool {
        guard let id = videoID else { return false }
        return SM.favoriteArr.contains("\(id)")
    }
}

class SearchM: NSObject {
    static let shared = SearchM()
    
    /**
          取得search頁面資料.
          - Parameter paramters: [String:String]
          - Parameter moreType : paramters.
          - completion : APIResult<[SupertasteSearchDiscountList], APIError>
    */
    func getSearchItemList( paramters: [String:String]? = nil, nextPage: String? = nil, completion: @escaping (_ response: APIResult<[SearchItemList], APIError>) -> ()) {
        
          let reachability = try! Reachability()
          reachability.whenReachable = { _ in
            guard reachability.connection != .unavailable else {
                return
            }
         
            AF.request(SEARCH_API, method: .get, parameters: paramters, encoding: URLEncoding.default ,headers: nil).responseArray(completionHandler: { (response:DataResponse<[SearchItemList], AFError>) in
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

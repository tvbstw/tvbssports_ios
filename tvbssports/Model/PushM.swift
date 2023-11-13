//
//  PushM.swift
//  videoCollection
//
//  Created by Eddie on 2021/11/30.
//  Copyright © 2021 Eddie. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import CocoaLumberjack
import Reachability

struct PushInitData: Mappable {
    var deviceID:String?
    var errorMsg:String?
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        deviceID <- map["id"]
        errorMsg <- map["error"]
    }
}


struct Push: Mappable {
    var pushType:String?
    var contentType:String?
    var title:String?
    var articleID:String?
    var url:String?
    var apiUrl:String?
    var categoryID:String?
    var categoryName:String?
    var publishDate:String?
    var attachment:String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        pushType     <- map["push_type"]
        contentType  <- map["content_type"]
        title        <- map["title"]
        articleID    <- map["article_id"]
        url          <- map["url"]
        apiUrl       <- map["api_url"]
        categoryID   <- map["category_id"]
        categoryName <- map["category_name"]
        publishDate  <- map["publish_date"]
        attachment   <- map["attachment"]
    }
}

class PushM: NSObject {
    static let shared = PushM()
    
    fileprivate override init() {}
    
    func initialSNS(paramters: Parameters? = nil, completion: @escaping (_ response: PushInitData) -> ()) {
        let reachability = try! Reachability()
        reachability.whenReachable = { _ in
            guard reachability.connection != .unavailable else {
                return
            }
            AF.request(INITIALSNS_API, method: .post, parameters: paramters, encoding: URLEncoding.default, headers: nil).responseObject(completionHandler: { (response:DataResponse<PushInitData, AFError>) in
                switch response.result {
                case .success(let responseData):
                    if let statusCode = response.response?.statusCode {
                        if statusCode == 200 {
                            completion(responseData)
                        } else {
                            DDLogError("get:success - statusCode:\(String(describing: response.response?.statusCode)) response.data:\(US.dataTransString(response.data))")
                        }
                    }
                case .failure(let error) :
                    DDLogError("get:error - statusCode:\(String(describing: response.response?.statusCode)) error:\(error)")
                }
            })
        }
        
        reachability.whenUnreachable = { _ in
            DDLogError("get:unreachable")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            DDLogInfo("Unable to start notifier")
        }
        reachability.stopNotifier()
    }
}

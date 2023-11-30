//
//  VersionM.swift
//  videoCollection
//
//  Created by tvbs on 2020/12/28.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

struct Version: Mappable {
    var version: String?
    var limitVersion: String?
    var releaseNote: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        version      <- map["version"]
        limitVersion <- map["limitversion"]
        releaseNote  <- map["releasenote"]
    }
}


class VersionM: NSObject {
    static let shared = VersionM()
    fileprivate override init() {}
    
    fileprivate var manager: Session {
        let manager = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest  = 10
        manager.session.configuration.timeoutIntervalForResource = 10
        return manager
    }
    
    func getVersionInfo(paramters: Parameters? = nil, completion: @escaping (_ response: Version) -> ()) {
        self.manager.request(VERSION_API, method: .get, parameters: paramters, encoding: URLEncoding.default, headers: nil).responseObject { (response:DataResponse<Version, AFError>) in
            switch response.result {
                case .success(let responseData):
                        completion(responseData)
                case .failure(let error) :
                    if error._code == NSURLErrorTimedOut {
                        print("Time out occurs!")
                    }
                    let locationVer = CURRENT_VERSION
                    DDLogError("get:error - statusCode:\(String(describing: response.response?.statusCode)) \(error)")
                    let data = Version(JSON:["version":locationVer,"limitversion":locationVer,"releasenote":""])
                    completion(data!)
            }
        }
    }
}

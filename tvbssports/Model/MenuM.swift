//
//  MenuM.swift
//  youtubeCollection
//
//  Created by leon on 2020/12/21.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack

struct Menu: Mappable {
    var layout: String?
    var ID: String?
    var name: String?
    var link: String?
    var category_name:String?
//    var playlistID: String?
    
    init?(map: Map) {}
    init(){}
    
    mutating func mapping(map: Map) {
        layout         <- map["layout"]
        ID             <- map["id"]
        name           <- map["title"]
        link           <- map["api_url"]
        category_name  <- map["fa_category_name"]
//        playlistID <- map["playlistID"]
    }
}

class MenuM: NSObject {
    static let shared = MenuM()
    fileprivate override init() {}
    fileprivate var manager: Session {
        let manager = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest  = 10
        manager.session.configuration.timeoutIntervalForResource = 10
        return manager
    }
    func getMenuInfo(paramters: Parameters? = nil, completion: @escaping (_ response: [Menu]) -> ()) {
        self.manager.request(MENU_API, method: .get, parameters: paramters, encoding: URLEncoding.default, headers: nil).responseArray { (response: DataResponse<[Menu], AFError>) in
            //DDLogDebug("response.data:\(US.dataTransString(response.data))")
            switch response.result {
                case .success(let responseData):
                    if let statusCode = response.response?.statusCode {
                        if statusCode == 200 {
                            if responseData.count > 0 {
                                completion(responseData)
                            } else {
                                DDLogError("get:success - empty statusCode:\(String(describing: response.response?.statusCode))")
                                let data = Menu(JSON: ["id":"empty","title":"empty","layout":"empty"])
                                completion([data!])
                            }
                        } else {
                            DDLogError("get:success - statusCode:\(String(describing: response.response?.statusCode))")
                        }
                    }
                case .failure(let error) :
                    if error._code == NSURLErrorTimedOut {
                        print("Time out occurs!")
                    }
                    DDLogError("get:error - statusCode:\(String(describing: response.response?.statusCode)) \(error)")
                    let data = Menu(JSON: ["id":"error","title":"error","layout":"error"])
                    completion([data!])
            }
        }
    }
    
}

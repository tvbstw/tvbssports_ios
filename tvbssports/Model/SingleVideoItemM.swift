//
//  SingleVideoItemM.swift
//  videoCollection
//
//  Created by Woody on 2022/4/12.
//  Copyright © 2022 Eddie. All rights reserved.
//

import CocoaLumberjack
import Reachability
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class SingleVideoItemM {}

extension SingleVideoItemM {
    class func getSingleVideo(apiUrl: String, paramters: String? = nil, completion: @escaping (_ response: Swift.Result<VideoItemContent, APIError>) -> ()) {
        
        let reachability = try! Reachability()
        reachability.whenReachable = { _ in
            guard reachability.connection != .unavailable else {
                return
            }
//            let apiPath = Util.shared.apiPath(apiUrl, paramters)
            DDLogInfo(apiUrl)
            AF.request(apiUrl, method: .get, encoding: URLEncoding.default, headers: nil).responseObject { (response:DataResponse<VideoList, AFError>) in
                switch response.result {
                case .success(let responseData):
                    if let statusCode = response.response?.statusCode,
                       statusCode == 200,
                       let item = responseData.videoData {
                        completion(.success(item))
                    } else {
                        completion(.failure(.init(type: .empty, localDesc: "data empty")))
                    }
                    
                case .failure(let error) :
                    DDLogError("get:error - statusCode:\(String(describing: response.response?.statusCode)) error:\(error)")
                    completion(.failure(.init(type: .error, localDesc: error.localizedDescription)))
                }
            }
        }
        
        reachability.whenUnreachable = { _ in
            DDLogError("get:unreachable")
            completion(.failure(.init(type: .unreachable, localDesc: "network unreachable")))
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            DDLogInfo("Unable to start notifier")
        }
        reachability.stopNotifier()
    }
}

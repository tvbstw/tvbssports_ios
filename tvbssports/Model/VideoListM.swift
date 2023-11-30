//
//  VideoListM.swift
//  videoCollection
//
//  Created by tvbs on 2020/12/28.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Reachability
import Alamofire
import AlamofireObjectMapper
import ObjectMapper


struct VideoList: Mappable {
    var type: String
    var apiStatusData: [APIStatus]?
    var videoData: VideoItemContent?
    var nextPageData: [NextPage]?
    
    init?(map: Map) {
        type = (try? map.value("type")) ?? ""
    }
    
    mutating func mapping(map: Map) {
        switch type {
            case "apiStatus":
                apiStatusData <- map["data"]
            case "video":
                videoData <- map["data"]
            case "nextPage":
                nextPageData <- map["data"]
            default:
                break
        }
    }
}
class VideoListM: NSObject {
    static let shared = VideoListM()
    var nextPage = ""
    fileprivate var menu:Menu?
    
    fileprivate override init() {}
    
    func getInfo(menu: Menu, paramters: String? = nil, completion: @escaping (_ response: [ChosenList]) -> ()) {
        self.menu = menu
        let reachability = try! Reachability()
        reachability.whenReachable = { _ in
            guard reachability.connection != .unavailable else {
                return
            }
            let apiPath = Util.shared.apiPath(menu.link!, paramters)
            DDLogInfo(apiPath)
            AF.request(apiPath, method: .get, encoding: URLEncoding.default, headers: nil).responseArray { (response:DataResponse<[VideoList], AFError>) in
                switch response.result {
                case .success(let responseData):
                    if let statusCode = response.response?.statusCode {
                        if statusCode == 200 {
                            if responseData.count > 0 {
                                let processData = self.refactor(responseData)
                                completion(processData)
                            } else {
                                DDLogError("get:success - empty statusCode:\(String(describing: response.response?.statusCode))")
                                let data = VideoList(JSON: ["type":"apiStatus","data":[["status":W_EMPTY]]])
                                let processData = self.refactor([data!])
                                completion(processData)
                            }
                        } else {
                            DDLogError("get:success - statusCode:\(String(describing: response.response?.statusCode))")
                            let data = VideoList(JSON: ["type":"apiStatus","data":[["status":W_ERROR]]])
                            let processData = self.refactor([data!])
                            completion(processData)
                        }
                    }
                case .failure(let error) :
                    DDLogError("get:error - statusCode:\(String(describing: response.response?.statusCode)) error:\(error)")
                    let data = VideoList(JSON: ["type":"apiStatus","data":[["status":W_ERROR]]])
                    let processData = self.refactor([data!])
                    completion(processData)
                }
            }
        }
        
        reachability.whenUnreachable = { _ in
            DDLogError("get:unreachable")
            let data = VideoList(JSON: ["type":"apiStatus","data":[["status":W_UNREACHABLE]]])
            let processData = self.refactor([data!])
            completion(processData)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            DDLogInfo("Unable to start notifier")
        }
        reachability.stopNotifier()
    }
    
    
    fileprivate func refactor(_ value:[VideoList]) -> [ChosenList] {
        var arr = [ChosenList]()
        if let menu = self.menu {
            for videoList in value {
                switch videoList.type {
                case "video":
                    if let video = videoList.videoData {

                        let list = ChosenList()
                        list.cellLayout = .video
                        list.videoItem = video

//                            list.faEvent = "click_article"
//                            list.faAction = "\(list.categoryEngNM)_article"
//                            list.faLabel = "\(list.title)_\(list.ID)_文章_\(list.categoryNM)頁"

                        
                        arr.append(list)

                    }

                case "apiStatus":
                    if let apiSArr = videoList.apiStatusData {
                        for apiS in apiSArr {
                            if let status = apiS.status {
                                let list = ChosenList()
                                list.cellLayout = .apiStatus
                                list.apiStatus = ErrorType(rawValue: status)!
                                arr.append(list)
                            }
                        }
                    }
                case "nextPage":
                    if let nextPageArr = videoList.nextPageData {
                        for nextPage in nextPageArr {
                            self.nextPage = Util.shared.checkNil(nextPage.nextPage)
                            if self.nextPage == "" {
                                let list = ChosenList()
                                list.cellLayout = .noMoreData
                                arr.append(list)
                            }
                        }
                        
                    }
                default:
                    break
                }
            }
        }
        return arr
    }
}


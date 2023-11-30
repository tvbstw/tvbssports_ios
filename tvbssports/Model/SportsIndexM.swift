//
//  SportsIndexM.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/22.
//  Copyright © 2023 Eddie. All rights reserved.
//


import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack


struct Prologue: Mappable {
    var prologueTitle:     String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        prologueTitle     <- map["prologue_title"]
    }
}
    
    
//prologue
//predict_rotate
//remain
//my_record
//hotNews_rotate
//AD
//issue-pack
    

//struct VideoIndex: Mappable {
//    var type:         String
//    var cellLayout:    CellLayout?
//    var headlineData:  [VideoIndexData]?
//    var categoryData:  [CategoryData]?
//    var pictureData:   [PictureList]?
//    var live:          VideoItemContent?
//    var video:         VideoItemContent?
//    var news:          ArticleListContent?
//    var apiStatusData: [APIStatus]?
//    var nextPageData:  [NextPage]?
//    init?(map: Map) {
//        type = (try? map.value("type")) ?? ""
//    }
//
//    mutating func mapping(map: Map) {
//        switch type {
//        case "headline":
//            cellLayout = .headline
//            headlineData  <- map["data"]
//        case "categorylist":
//            cellLayout = .category
//            categoryData  <- map["data"]
//        case "picturelist":
//            cellLayout = .picture
//            pictureData   <- map["data"]
//        case "live":
//            cellLayout = .live
//            live          <- map["data"]
//        case "video":
//            cellLayout = .video
//            video         <- map["data"]
//        case "news":
//            cellLayout = .news
//            news          <- map["data"]
//        case "apiStatus":
//            cellLayout = .apiStatus
//            apiStatusData <- map["data"]
//        case "nextPage":
//            nextPageData  <- map["data"]
//        default:
//            break
//        }
//    }
//}
//
//
//struct VideoIndexData: Mappable {
//    var videoID:   String?
//    var title:     String?
//    var image:     String?
//    var publish:   String?
//    var enName:    String?
//    var name:      String?
//    var live:      String?
//    var videoTime: String?
//    var newsID:    String?
//    var apiUrl:    String?
//    var type:      String?
//    var openType:  OpenType?
//
//    init?(map: Map) {}
//
//    mutating func mapping(map: Map) {
//        videoID   <- map["video_id"]
//        title     <- map["title"]
//        image     <- map["image"]
//        publish   <- map["publish"]
//        enName    <- map["en_name"]
//        name      <- map["name"]
//        live      <- map["live"]
//        videoTime <- map["video_time"]
//        newsID    <- map["news_id"]
//        apiUrl    <- map["api_url"]
//        type      <- map["type"]
//        openType = OpenType(rawValue: (try? map.value("open_type")) ?? "")
//    }
//
//    enum OpenType: String {
//        case browser, inAppBrowser, native
//    }
//}
//
//struct CategoryData: Mappable {
//    var cID:           String?
//    var title:         String?
//    var image:         String?
//    var layout:        String?
//    var apiUrl:        String?
//    var category_name: String?
//
//    init?(map: Map) { }
//
//    mutating func mapping(map: Map) {
//        cID            <- map["id"]
//        title          <- map["title"]
//        image          <- map["image"]
//        layout         <- map["layout"]
//        apiUrl         <- map["api_url"]
//        category_name  <- map["fa_category_name"]
//    }
//}
//
//struct PictureData: Mappable {
//    var pID:         Int?
//    var name:        String?
//    var description: String?
//    var coverH:      String?
//    var coverV:      String?
//    var publish:     String?
//
//    init?(map: Map) { }
//
//    mutating func mapping(map: Map) {
//        pID         <- map["id"]
//        name        <- map["name"]
//        description <- map["description"]
//        coverH      <- map["cover_h"]
//        coverV      <- map["cover_v"]
//        publish     <- map["publish_at"]
//    }
//}


class SportsIndexM: NSObject {
    static let shared = SportsIndexM()
    fileprivate override init() {}
    
}

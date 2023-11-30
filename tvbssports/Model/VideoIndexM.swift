//
//  VideoIndexM.swift
//  videoCollection
//
//  Created by Eddie on 2021/12/8.
//  Copyright © 2021 Eddie. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack


struct VideoIndex: Mappable {
    var type:         String
    var cellLayout:    CellLayout?
    var headlineData:  [VideoIndexData]?
    var categoryData:  [CategoryData]?
    var pictureData:   [PictureList]?
    var live:          VideoItemContent?
    var video:         VideoItemContent?
    var news:          ArticleListContent?
    var apiStatusData: [APIStatus]?
    var nextPageData:  [NextPage]?
    init?(map: Map) {
        type = (try? map.value("type")) ?? ""
    }
    
    mutating func mapping(map: Map) {
        switch type {
        case "headline":
            cellLayout = .headline
            headlineData  <- map["data"]
        case "categorylist":
            cellLayout = .category
            categoryData  <- map["data"]
        case "picturelist":
            cellLayout = .picture
            pictureData   <- map["data"]
        case "live":
            cellLayout = .live
            live          <- map["data"]
        case "video":
            cellLayout = .video
            video         <- map["data"]
        case "news":
            cellLayout = .news
            news          <- map["data"]
        case "apiStatus":
            cellLayout = .apiStatus
            apiStatusData <- map["data"]
        case "nextPage":
            nextPageData  <- map["data"]
        default:
            break
        }
    }
}

extension VideoIndex {
    var isCategorylist: Bool {
        return self.type == "categorylist"
    }
}

struct VideoIndexData: Mappable {
    var videoID:   String?
    var title:     String?
    var image:     String?
    var publish:   String?
    var enName:    String?
    var name:      String?
    var live:      String?
    var videoTime: String?
    var newsID:    String?
    var apiUrl:    String?
    var type:      String?
    var openType:  OpenType?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        videoID   <- map["video_id"]
        title     <- map["title"]
        image     <- map["image"]
        publish   <- map["publish"]
        enName    <- map["en_name"]
        name      <- map["name"]
        live      <- map["live"]
        videoTime <- map["video_time"]
        newsID    <- map["news_id"]
        apiUrl    <- map["api_url"]
        type      <- map["type"]
        openType = OpenType(rawValue: (try? map.value("open_type")) ?? "")
    }
    
    enum OpenType: String {
        case browser, inAppBrowser, native
    }
}

struct CategoryData: Mappable {
    var cID:           String?
    var title:         String?
    var image:         String?
    var layout:        String?
    var apiUrl:        String?
    var category_name: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        cID            <- map["id"]
        title          <- map["title"]
        image          <- map["image"]
        layout         <- map["layout"]
        apiUrl         <- map["api_url"]
        category_name  <- map["fa_category_name"]
    }
}

extension CategoryData {
    
    var menu: Menu {
        var menu = Menu()
        menu.layout = self.layout
        menu.ID = self.cID
        menu.link = self.apiUrl
        menu.category_name = self.category_name
        menu.name = self.title
        return menu
    }
}


struct PictureData: Mappable {
    var pID:         Int?
    var name:        String?
    var description: String?
    var coverH:      String?
    var coverV:      String?
    var publish:     String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        pID         <- map["id"]
        name        <- map["name"]
        description <- map["description"]
        coverH      <- map["cover_h"]
        coverV      <- map["cover_v"]
        publish     <- map["publish_at"]
    }
}

//
//  BaseList.swift
//  videoCollection
//
//  Created by leon on 2020/12/23.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

struct APIStatus: Mappable {
    var status: String?
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        status <- map["status"]
    }
}

struct NextPage: Mappable {
    var nextPage: String?
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        nextPage <- map["nextPage"]
    }
}

class BaseList: NSObject {
    var cellLayout: CellLayout
    var apiStatus: ErrorType
    var ID: String
    var title: String
    var image: String
    var contentLink: String
    var shareUrl: String
    var categoryEngNM: String
    var categoryNM: String
    var dateTime: String
    var contentType: ContentType
    
    override init() {
        self.cellLayout = .default
        self.apiStatus = .default
        self.ID = ""
        self.title = ""
        self.image = ""
        self.contentLink = ""
        self.shareUrl = ""
        self.categoryEngNM = ""
        self.categoryNM = ""
        self.dateTime = ""
        self.contentType = .default
    }
}

class ChosenList: BaseList {
    var videoItem:VideoItemContent?
    var artcleItem:ArticleListContent?
    var artcleListRotateList:[ArticleListContent]?
    var headlineData: [VideoIndexData]?
    var categoryData: [CategoryData]?
}

extension ChosenList {
    var isLive: Bool {
        return videoItem?.isLive ?? false
    }
    
}

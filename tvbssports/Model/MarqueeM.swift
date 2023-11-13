//
//  MarqueeM.swift
//  videoCollection
//
//  Created by Eddie on 2022/6/21.
//  Copyright © 2022 Eddie. All rights reserved.
//

import ObjectMapper

struct Marquee: Mappable {
    var isShow:  Bool?
    var content: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        isShow   <- map["isShow"]
        content  <- map["content"]
    }
}

//
//  Configure.swift
//  videoCollection
//
//  Created by darren on 2020/12/24.
//  Copyright © 2020 leon. All rights reserved.
//


public struct segueIdentify {
    public static let searchContent   = "searchContentSegue"
}

enum APIResult<T,E> {
    case success(T)
    case failure(E: APIError)
}

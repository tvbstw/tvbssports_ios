//
//  Error.swift
//  supertastemvp
//
//  Created by darren on 2020/3/5.
//  Copyright © 2020 Eddie. All rights reserved.
//

import Foundation


//public enum APIErrorType {
//     case tokenError
//     case error
//     case system
//     case JsonError
//     case network
//     case service
//     case statusCode
//}

struct EncodeError:Error {
    
    let type:ErrorType
    let description:String
    
    init(type:ErrorType , localDesc:String) {
        self.type = type
        self.description = localDesc
    }
}

extension EncodeError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString(description, comment: "")
    }
}


struct APIError:Error {

    let type:ErrorType
    let description:String
    
    init(type:ErrorType , localDesc:String) {
        self.type = type
        self.description = localDesc
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString(description, comment: "")
    }
}

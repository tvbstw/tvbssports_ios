//
//  PictureListM.swift
//  videoCollection
//
//  Created by darrenChiang on 2022/6/21.
//  Copyright © 2022 Eddie. All rights reserved.
//

import CocoaLumberjack
import Reachability
import Alamofire
import AlamofireObjectMapper
import ObjectMapper


struct PictureList: Mappable {
    
    var pictureId : Int?
    var name: String?
    var description: String?
    var cover_h: String?
    var cover_v: String?
    var publish_at: String?


    
    init?(map: Map) {}
    mutating func mapping(map: Map) {
        pictureId      <- map["id"]
        name           <- map["name"]
        description    <- map["description"]
        cover_h        <- map["cover_h"]
        cover_v        <- map["cover_v"]
        publish_at     <- map["publish_at"]
      
    }
}


struct PictureContent: Mappable {
    
    var id: Int?
    var name: String?
    var description: String?
    var cover_h: String?
    var cover_v: String?
    var publish_at: String?
    var pictures:[PictureImage]?
  
    
    init?(map: Map) {}
    mutating func mapping(map: Map) {
        id             <- map["id"]
        name           <- map["name"]
        description    <- map["description"]
        cover_h        <- map["cover_h"]
        cover_v        <- map["cover_v"]
        publish_at     <- map["publish_at"]
        pictures       <- map["pictures"]
      
    }
}

struct PictureImage: Mappable {
    
    var image: String?
    var text: String?

    init(image:String = "", text:String = "") {
         self.text = text
         self.image = image
     }
    
    init?(map: Map) {}
    mutating func mapping(map: Map) {
        image             <- map["image"]
        text              <- map["text"]
    }
}


class PictureListM: NSObject {
    static let shared = PictureListM()
    fileprivate override init() {}
    
    /**
          取得圖籍列表頁.
          - completion : APIResult<[PictureList], APIError>
    */
    func getPictureList( completion: @escaping (_ response: APIResult<[PictureList], APIError>) -> ()) {
        
          let reachability = try! Reachability()
          reachability.whenReachable = { _ in
              guard reachability.connection != .unavailable else {
                  return
              }
            AF.request(PICTURELIST_API, method: .get, encoding: URLEncoding.default ,headers: nil).responseArray(completionHandler: { (response:DataResponse<[PictureList], AFError>) in
                  switch response.result {
                  case .success(let responseData):
                      if let statusCode = response.response?.statusCode {
                          if statusCode == 200 {
                              guard  responseData.count != 0 else {
                                  completion(.failure(E: APIError(type: .empty, localDesc: "data empty")))
                                  return
                              }
                              completion(.success(responseData))
                          } else {
                            let statusCode = (String(describing: response.response?.statusCode))
                            DDLogError("get:success - statusCode:\(statusCode)")
                            completion(.failure(E: APIError(type: .service, localDesc: statusCode)))
                          }
                      }
                  case .failure(let error):
                      DDLogError("get:error - statusCode:\(String(describing: response.response?.statusCode)) error:\(error)")
                     completion(.failure(E: APIError(type: .error, localDesc: error.localizedDescription)))
                  }
              })
          }
          
          reachability.whenUnreachable = { _ in
              DDLogError("get:unreachable")
            completion(.failure(E: APIError(type: .network, localDesc: "network unreachable")))
          }
          
          do {
              try reachability.startNotifier()
          } catch {
              DDLogInfo("Unable to start notifier")
          }
          reachability.stopNotifier()
      }
    
    
    /**
          取得圖輯內容頁.
          - completion : APIResult<[SupertasteSearchDiscountList], APIError>
    */
    func getPictureContent(pictureId:String, completion: @escaping (_ response: APIResult<[PictureContent], APIError>) -> ()) {
        
          let reachability = try! Reachability()
          reachability.whenReachable = { _ in
              guard reachability.connection != .unavailable else {
                  return
              }
              
              let url = PICTURECONTENT_API + "/\(pictureId)"
              
              AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseArray(completionHandler: { (response:DataResponse<[PictureContent], AFError>) in
                  switch response.result {
                  case .success(let responseData):
                      if let statusCode = response.response?.statusCode {
                          if statusCode == 200 {
                  
                              guard  responseData.count != 0 else {
                                  completion(.failure(E: APIError(type: .empty, localDesc: "data empty")))
                                  return
                              }
                              completion(.success(responseData))
                          } else {
                            let statusCode = (String(describing: response.response?.statusCode))
                      DDLogError("get:success - statusCode:\(statusCode)")
                            completion(.failure(E: APIError(type: .service, localDesc: statusCode)))
                          }
                      }
                  case .failure(let error):
                      DDLogError("get:error - statusCode:\(String(describing: response.response?.statusCode)) error:\(error)")
                     completion(.failure(E: APIError(type: .error, localDesc: error.localizedDescription)))
                  }
              })

          }
          
          reachability.whenUnreachable = { _ in
              DDLogError("get:unreachable")
            completion(.failure(E: APIError(type: .network, localDesc: "network unreachable")))
          }
          
          do {
              try reachability.startNotifier()
          } catch {
              DDLogInfo("Unable to start notifier")
          }
          reachability.stopNotifier()
      }
    
    
///PictureListM end
}

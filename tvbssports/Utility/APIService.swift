//
//  APIService.swift
//  woman
//
//  Created by Eddie on 2022/5/10.
//  Copyright © 2022 Eddie. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import Reachability

let serialAPIQueue = DispatchQueue(label: "com.api.serial")

enum TVBSAPIResult<S, F> where F : Error {
    case success(S)
    case failure(F)
}

enum TVBSAPIError: Error, Equatable {
    case noNetwork
    case requestFail
    case responseEmpty
    case transformFail
    case failure(Error)
    
    static func == (lhs: TVBSAPIError, rhs: TVBSAPIError) -> Bool {
        switch (lhs, rhs) {
        case (.noNetwork, .noNetwork):
            return true
        default:
            return false
        }
    }
}

protocol TVBSRequest: URLRequestConvertible {
    associatedtype TVBSResponse
    var urlPath: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var encoding: ParameterEncoding { get }
    var session: Session { get }
}

extension TVBSRequest {
    var method: HTTPMethod {
        .get
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
    
    var session: Session {
        let manager = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest  = 10
        manager.session.configuration.timeoutIntervalForResource = 10
        return manager
    }
}

extension TVBSRequest {
    func asURLRequest() throws -> URLRequest {
        let url = try urlPath.asURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        return try encoding.encode(urlRequest, with: parameters)
    }
}

extension TVBSRequest {
    func networkCheck(completion: @escaping((_ status: Bool) -> Void)) {
        let reachability = try! Reachability()
        reachability.whenReachable = { _ in
            guard reachability.connection != .unavailable else {
                completion(false)
                return
            }
            switch reachability.connection {
            case .cellular, .wifi:
                completion(true)
            case .unavailable, .none:
                completion(false)
            }
        }
        
        reachability.whenUnreachable = { _ in
            completion(false)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            
        }
        reachability.stopNotifier()
    }
}

extension TVBSRequest where TVBSResponse: BaseMappable {
    func fetchDataForArray(completion: @escaping(_ result: (TVBSAPIResult<[TVBSResponse], TVBSAPIError>)) -> Void) {
        networkCheck { status in
            switch status {
            case true:
                guard let urlRequest = urlRequest else {
                    completion(.failure(.requestFail))
                    return
                }
                session.request(urlRequest)
                    .validate()
                    .responseArray(queue: serialAPIQueue) { (response: DataResponse<[TVBSResponse], AFError>) in
                    switch response.result {
                    case .success(let r):
                        guard r.count > 0 else {
                            completion(.failure(.responseEmpty))
                            return
                        }
                        completion(.success(r))
                    case .failure(let error):
                        completion(.failure(.failure(error)))
                    }
                }
            case false:
                completion(.failure(.noNetwork))
            }
        }
    }
}

extension TVBSRequest where TVBSResponse: BaseMappable {
    func fetchDataForObject(completion: @escaping(_ result: (TVBSAPIResult<TVBSResponse, TVBSAPIError>)) -> Void) {
        networkCheck { status in
            switch status {
            case true:
                guard let urlRequest = urlRequest else {
                    completion(.failure(.requestFail))
                    return
                }
                session.request(urlRequest)
                    .validate()
                    .responseObject(queue: serialAPIQueue) { (response: DataResponse<TVBSResponse, AFError>) in
                        switch response.result {
                        case .success(let r):
                            completion(.success(r))
                        case .failure(let error):
                            completion(.failure(.failure(error)))
                        }
                }
            case false:
                completion(.failure(.noNetwork))
            }
        }
    }
}

extension TVBSRequest {
    func fetchDataForJson(completion: @escaping(_ result: (TVBSAPIResult<Any, TVBSAPIError>)) -> Void) {
        networkCheck { status in
            switch status {
            case true:
                guard let urlRequest = urlRequest else {
                    completion(.failure(.requestFail))
                    return
                }
                session.request(urlRequest)
                    .validate()
                    .responseJSON(queue: serialAPIQueue) { (response: AFDataResponse<Any>) in
                        switch response.result {
                        case .success(let r):
                            completion(.success(r))
                        case .failure(let error):
                            completion(.failure(.failure(error)))
                        }
                    }
            case false:
                completion(.failure(.noNetwork))
            }
        }
    }
}

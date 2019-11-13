//
//  NetworkManager.swift
//  Coomo
//
//  Created by Umair on 20/10/2019.
//  Copyright © 2019 Umair. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

// Add Alamofire pod in project

// MARK: -

struct ServiceResponse<Value: Codable>: Codable {
    let data: Value?
    let error: [String]?

    enum CodingKeys: String, CodingKey {
        case data
        case error
    }
}

// MARK: -

enum ServiceError: Error {
    case noInternet
}

extension ServiceError: LocalizedError {
    
    var errorDescription: String? {
        
        switch self {
        case .noInternet:
            return "Internet not available."
        }
    }
}

// MARK: -

let InvalidStatusCode = -999999
typealias StatusCode = Int
typealias ServiceResult<Value: Codable> = Result<ServiceResponse<Value>, Error>

// MARK: -

class NetworkManager {
    
    // MARK: -
    
    class var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    // MARK: -
   
//    @discardableResult
    class func makeRequest<Value: Codable>(config: APIConfig, completion: @escaping ((ServiceResult<Value>, StatusCode) -> Void)) {
        
        if NetworkManager.isConnectedToInternet {
            let baseURL = AppTarget.current.serverBasePath()
            
            let completePath = baseURL + config.path
            var headers = HTTPHeaders()
            
            if config.headers != nil {
                headers = config.headers!
            }
            
            if config.setAuth {
                headers.add(name: "Authorization", value: "TokenString")
            }
            
            Alamofire.Session.default.request(completePath, method: config.method, parameters: config.parameters, encoding: config.encoding, headers: headers).responseDecodable { (response: DataResponse<ServiceResponse<Value>, AFError>) in
                
                print("Calling Endpoint: \(response.request?.url?.absoluteString ?? "EmptyURL")")
                print("Passed Parameters: \(String(describing: config.parameters))")

                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Raw Data Response: \(utf8Text)")
                }
                
                let statusCodeReceived = response.response?.statusCode ?? InvalidStatusCode

                switch response.result {
                case .success(let value):
                    completion(.success(value), statusCodeReceived)
                case .failure(let error):
                    completion(.failure(error), statusCodeReceived)
                }
            }
            
        } else {
            completion(.failure(ServiceError.noInternet), InvalidStatusCode)
        }
    }
}

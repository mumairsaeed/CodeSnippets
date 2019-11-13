//
//  APIConfig.swift
//  Coomo
//
//  Created by Umair on 20/10/2019.
//  Copyright © 2019 Umair. All rights reserved.
//

import Foundation
import Alamofire

// Add Alamofire pod in project

// MARK: -

protocol APIConfig {
    var method: HTTPMethod { get }
    var path: String { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
    var setAuth: Bool { get }
}

// MARK: -

extension APIConfig {
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var setAuth: Bool {
        return true
    }
    
}

// MARK: - How to Use

// Sample classes
// Create enum and add you api call infos
enum UserAPIConfig: APIConfig {
    
    case login(email: String, password: String)
    
    var method: HTTPMethod {
        
        switch self {
            
        case .login:
            return .post
        }
    }
    
    var path: String {
        
        switch self {
            
        case .login:
            return "login"
        }
    }
    
    var parameters: Parameters? {
        
        switch self {

        case .login(let email, let password):
            let params = ["email" : email, "password" : password]
            return params
        }

    }
    
    var headers: HTTPHeaders? {
        
        switch self {
            
        case .login:
            return nil
        }
    }
    
    var setAuth: Bool {
        
        switch self {
            
        case .login:
            return false
        }
    }
    
    var encoding: ParameterEncoding {
        
        switch self {
            
        case .login:
            return JSONEncoding.default
        }
    }
}

// Call the network manager

class ServerClient {
    
    static func loginWithEmail(config: UserAPIConfig, completion: @escaping (_ success: Bool, _ errorMessage: String) -> Void) {
    
        NetworkManager.makeRequest(config: config) { (result: Result<ServiceResponse<User>, Error>, statusCode) in
            
            var success = false
            var errorMessage = "Something went wrong. Please try again."
            
            switch result {
            case .success(let value):
                
                if statusCode == 200 && value.data != nil {
                    success = true
                    
                } else {
 
                }

            case .failure(let error):
                errorMessage = error.localizedDescription
            }
            
            completion(success, errorMessage)
        }
    }
}

// Sample call
//let config = UserAPIConfig.login(email: email, password: password)

//ServerClient.loginWithEmail(config: config) { [weak self] (success, errorMessage) in
//    guard let strongSelf = self else { return }
//
//}


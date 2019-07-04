//
//  FacebookHandler.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import Foundation

import FacebookCore

struct MyProfileRequest: GraphRequestProtocol {
    struct Response: GraphResponseProtocol {
        init(rawResponse: Any?) {
            // Decode JSON from rawResponse into other properties here.
        }
    }
    
    var graphPath = "/me"
    var parameters: [String : Any]? = ["fields": "cover,picture.type(large),id,name,first_name,last_name,gender,email,location,birthday"]
    var accessToken = AccessToken.current
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = .defaultVersion
}

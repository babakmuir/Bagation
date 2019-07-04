//
//  User.swift
//  Bagation
//
//  Created by vivek soni on 29/01/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import ObjectMapper

class User: Mappable {
    var userId:String = ""
    var email:String = ""
    var password:String = ""
    var token:String = ""
    var fullname:String = ""
    var phoneno:String = ""
    var latitude:String = ""
    var longitude:String = ""
    var imagepath:String = ""
    var userType:String = ""  //1 = Traveller , 2= Bag Handler
    var fbId:String = ""
    var StoreDesc:String = "" //Using as ABN Field
    var BagSpace:String = ""
    var StoreName:String = ""
    var Address:String = ""
    var startTime:String = ""
    var endTime:String = ""
    
    static let shared = User()
    
    init() {
        
    }
    
    var type: AppMode {
        //scope.contains("foodpoint") ? 0 : 1
        return AppMode(value: 0)
    }
    
    required init?(map: Map) {
        self.mapping(map: map)
    }
    
    convenience init(dic : [String : Any]) {
        let map = Map.init(mappingType: .fromJSON, JSON: dic)
        self.init(map:map)!
    }
    
    func deleteUser() {
        userId = ""
        email = ""
        password = ""
        token = ""
        fullname = ""
        latitude = ""
        longitude = ""
        imagepath = ""
        fbId = ""
        phoneno = ""
        userType = ""
        StoreDesc = ""
        StoreName = ""
        Address = ""
        BagSpace = ""
        startTime = ""
        endTime = ""
        saveUser(user: self)
    }
    
    func loadUser() {
        let userDef = UserDefaults.standard
        if ((userDef.string(forKey: Constants.Key_UserData)) != nil) {
            let uString = UserDefaults.standard.value(forKey: Constants.Key_UserData) as! String
            let mapper = Mapper<User>()
            let userObj = mapper.map(JSONString: uString)
            let map = Map.init(mappingType: .fromJSON, JSON: (userObj?.toJSON())!)
            self.mapping(map:map)
        }
    }
    
    func saveUser(user:User) {
        UserDefaults.standard.set(user.toJSONString()!, forKey: Constants.Key_UserData)
        UserDefaults.standard.synchronize()
        loadUser()
    }
    
    // Mappable
    func mapping(map: Map) {
        userId              <- map["userId"]
        email               <- map["email"]
        password            <- map["password"]
        token               <- map["deviceToken"]
        fullname            <- map["fullname"]
        latitude            <- map["latitude"]
        longitude           <- map["longitude"]
        imagepath           <- map["imagepath"]
        phoneno             <- map["phoneno"]
        fbId                <- map["fbid"]
        userType            <- map["userType"]
        StoreDesc            <- map["StoreDesc"]
        BagSpace            <- map["BagSpace"]
        StoreName            <- map["StoreName"]
        Address            <- map["Address"]
        startTime            <- map["StartTime"]
        endTime            <- map["EndTime"]
    }
}

class FBUser: Mappable {
    
    
    var email:String = ""
    var fullname:String = ""
    var imagepath:String = ""
    var fbId:String = ""
    
    static let shared = FBUser()
    
    init() {
        
    }
    
    required init?(map: Map) {
        self.mapping(map: map)
    }
    
    convenience init(dic:[String:Any]) {
        let map = Map.init(mappingType: .fromJSON, JSON: dic)
        self.init(map:map)!
    }
    
    func mapping(map: Map) {
        email               <- map["email"]
        fullname            <- map["user_info.fullname"]
        imagepath            <- map["user_logo.logopath"]
        fbId                <- map["id"]
    }
}

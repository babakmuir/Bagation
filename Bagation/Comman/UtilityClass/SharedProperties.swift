//
//  SharedProperties.swift
//  HiringAlerts
//
//  Created by Vivek Soni on 10/01/17.
//  Copyright © 2017 Vivek Soni. All rights reserved.
//

import UIKit

class SharedProperties: NSObject {
    
    // Userdefault
    static let objDefault = UserDefaults.standard
    
    
    // Mark:- 
    class func setLoggedIn() {
        self.objDefault.setValue("yes", forKey: Constants.Key_UserLogggedIn)
        self.objDefault.setValue("\(User.shared.userType)", forKey: Constants.Key_UserLogggedInType)
    }
    
    class func setLoggedOut() {
        self.objDefault.setValue(nil, forKey:  Constants.Key_UserLogggedIn)
       
        //Remove all store user default.
        for key in Array(self.objDefault.dictionaryRepresentation().keys) {
            self.objDefault.removeObject(forKey: key)
        }
    }
    
    class func checkLoggedIn() -> Bool {
        return ((self.objDefault.value(forKey:  Constants.Key_UserLogggedIn) != nil))
    }
    
    class func getBuildVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        //let build = dictionary["CFBundleVersion"] as! String
        //"\(version) build \(build)"
        return "Version Number: \(version)"
    }
    
    /*class func setDefaultProfile(profileType:String) {
       
        UserDAO.sharedInstance.user.defaultProfileType = profileType
        self.objDefault.set(profileType, forKey: kUserDefaultProfile)
    }
    
    class func getDefaultProfile() -> String {
        if (self.objDefault.value(forKey: kUserDefaultProfile) != nil) {
            UserDAO.sharedInstance.user.defaultProfileType = self.objDefault.value(forKey: kUserDefaultProfile) as! String
            return self.objDefault.value(forKey: kUserDefaultProfile) as! String
        }
        return ""
    }*/
    
}




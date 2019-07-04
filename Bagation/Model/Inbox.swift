//
//  Inbox.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import Foundation
import UIKit

class Inbox {
    
    var date:String! = ""
    var isSeen:Bool! = false
    var receiverID:String! = ""
    var receiverName:String! = ""
    var senderName:String! = ""
    var text:String! = ""
    var userID:String! = ""
    var receiverPic:String! = ""
    var receiverDeviceToken:String! = ""
    var receiverOnlineStatus:String! = ""
    
    init(inboxDict:[String:Any]) {
        
        if let value = inboxDict["date"] {
            self.date = value as? String
        }
        if let value = inboxDict["isSeen"] {
            self.isSeen = value as? Bool
        }
        if let value = inboxDict["receiver_id"] {
            self.receiverID = value as? String
        }
        if let value = inboxDict["receiver_name"] {
            self.receiverName = value as? String
        }
        if let value = inboxDict["sender_name"] {
            self.senderName = value as? String
        }
        if let value = inboxDict["text"] {
            self.text = value as? String
        }
        if let value = inboxDict["user_id"] {
            self.userID = value as? String
        }
        if let value = inboxDict["receiver_pic"] {
            self.receiverPic = value as? String
        }

    }
}




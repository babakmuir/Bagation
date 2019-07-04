//
//  Chat.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import Foundation
import UIKit

class Chat {
    
    var name:String! = ""
    var senderName:String! = ""
    var text:String! = ""
    var receiverID:String! = ""
    var userID:String! = ""
    var date:String! = ""
    var mediaType:messageType! = .text

    init(chatDict:[String:Any]) {
        self.name = chatDict["receiver_name"] as? String
        self.senderName = chatDict["sender_name"] as? String
        self.receiverID = chatDict["receiver_id"] as? String
        self.text = chatDict["text"] as? String
        self.userID = chatDict["user_id"] as? String
        self.date = chatDict["date"] as? String
        
        let type:String = chatDict["mediaType"] as! String
        if type == "1" {
            mediaType = .image
        }else {
            mediaType = .text
        }
    }
    
    
}

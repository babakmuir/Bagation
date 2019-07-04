//
//  StorageDAO.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import Foundation
import UIKit

class StorageDAO {
    var BagHandlerID:String! = ""
    var Address:String! = ""
    var TotalAmount:String! = ""
    var EndDate:String! = ""
    var NoOfBags:String! = ""
    var PaymentStatus:String! = ""
    var Phone:String! = ""
    var BagHanlderPhone:String! = ""
    
    var Price:String! = ""
    var StartDate:String! = ""
    var StoreDesc:String! = ""
    var StoreName:String! = ""
    var FirBaseID:String! = ""
    var DisplayName:String! = ""
    var BagHandlerFireBaseID:String! = ""
    var OrderID:String! = ""
    var SpaceReleasedStatus:String! = ""
    
    var FirebaseReceiverDeviceToken:String! = ""
    var FirebaseReceiverOnlineStatus:String! = ""
    
    init(storageDict:[String:Any]) {
        if let obj = storageDict["Address"] {
            self.Address = obj as? String
        }
        if let obj = storageDict["BagHandlerID"] {
            self.BagHandlerID = "\(obj)"
        }
        if let obj = storageDict["BagHandlerFireBaseID"] {
            self.BagHandlerFireBaseID = "\(obj)"
        }
        if let obj = storageDict["EndDate"] {
            self.EndDate = "\(obj)"
        }
        if let obj = storageDict["NoOfBags"] {
            self.NoOfBags = "\(obj)"
        }
        if let obj = storageDict["PaymentStatus"] {
            self.PaymentStatus = "\(obj)"
        }
        if let obj = storageDict["Phone"] {
            self.Phone = "\(obj)"
        }
        if let obj = storageDict["BagHandlerPhone"] {
            self.BagHanlderPhone = "\(obj)"
        }
        
        if let obj = storageDict["Price"] {
            self.Price = "\(obj)"
        }
        if let obj = storageDict["StartDate"] {
            self.StartDate = "\(obj)"
        }
        if let obj = storageDict["StoreDesc"] {
            self.StoreDesc = obj as? String
        }
        if let obj = storageDict["StoreName"] {
            self.StoreName = obj as? String
        }
        if let obj = storageDict["TotalAmount"] {
            self.TotalAmount = "\(obj)"
        }
        if let obj = storageDict["FirBaseID"] {
            self.FirBaseID = obj as? String
        }
        if let obj = storageDict["DisplayName"] {
            self.DisplayName = obj as? String
        }
        if let obj = storageDict["OrderID"] {
            self.OrderID = "\(obj)"
        }
        if let obj = storageDict["IsReleased"] {
            self.SpaceReleasedStatus = "\(obj)"
        }
        
    }
    
}
class FirebaseInfo {
    var name:String! = ""
    var ID:String! = ""
    var image:String! = ""
    var deviceToken:String! = ""
    var onlineStatus:String! = "false"
    
    init(dict:[String:Any]) {
        
        if let obj = dict["isOnline"] {
            self.onlineStatus = obj as? String
        }
        
        if let obj = dict["deviceToken"] {
            self.deviceToken = obj as? String
        }
        
        if let obj = dict["image"] {
            self.image = obj as? String
        }
        if let obj = dict["firebase_id"] {
            self.ID = obj as? String
        }
        if let obj = dict["name"] {
            self.name = obj as? String
        }
        
    }
    
}


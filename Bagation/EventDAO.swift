//
//  EventDAO.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import Foundation

class EventDAO {
    
    var BagHandlerID:String! = ""
    var DisplayName:String! = ""
    var FirBaseID:String! = ""
    var NoOfBags:String! = ""
    var OrderID:String! = ""
    var PaymentStatus:String! = ""
    var Phone:String! = ""
    var Price:String! = ""
    var TotalAmount:String! = ""
    var UserID:String! = ""
    var EndDate:Date?
    var StartDate:Date?

    init(eventDict:[String:Any]) {
        self.BagHandlerID = "\(eventDict["BagHandlerID"]!)"
        self.DisplayName = "\(eventDict["DisplayName"]!)"
        self.FirBaseID = "\(eventDict["FirBaseID"]!)"
        self.NoOfBags = "\(eventDict["NoOfBags"]!)"
        self.OrderID = "\(eventDict["OrderID"]!)"
        self.PaymentStatus = "\(eventDict["PaymentStatus"]!)"
        self.Phone = "\(eventDict["Phone"]!)"
        self.Price = "\(eventDict["Price"]!)"
        self.TotalAmount = "\(eventDict["TotalAmount"]!)"
        self.UserID = "\(eventDict["UserID"]!)"
        let date = "\(eventDict["EndDate"]!)"
        let date1 = "\(eventDict["StartDate"]!)"
        self.EndDate = self.convertTime(strDate: date)
        self.StartDate = self.convertTime(strDate: date1)

    }
    
    func convertTime(strDate:String) -> Date{
        print(strDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dt = dateFormatter.date(from: strDate)
     
        dateFormatter.dateFormat = "dd MMM HH:mm"
        dateFormatter.timeZone = TimeZone.current
        let newDate = dateFormatter.string(from: dt!)
        print(newDate)
        
        return dt!
        /*
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
//        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: strDate)!
        return date
 */
    }
    
    /*
     func localToUTC(date:String) -> String {
     let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = "h:mm a"
     dateFormatter.calendar = NSCalendar.current
     dateFormatter.timeZone = TimeZone.current
     
     let dt = dateFormatter.date(from: date)
     dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
     dateFormatter.dateFormat = "H:mm:ss"
     
     return dateFormatter.string(from: dt!)
     }
     
     func UTCToLocal(date:String) -> String {
     let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = "H:mm:ss"
     dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
     
     let dt = dateFormatter.date(from: date)
     dateFormatter.timeZone = TimeZone.current
     dateFormatter.dateFormat = "h:mm a"
     
     return dateFormatter.string(from: dt!)
     }
 */
}


/*
 BagHandlerID = 15;
 DisplayName = "vivek soni";
 FirBaseID = MWwKjAUb5BVQkl0FtoLGtcbKJax1;
 NoOfBags = 2;
 OrderID = 13;
 PaymentStatus = 1;
 Phone = 9876543212;
 Price = 4;
 TotalAmount = "88.00";
 UserID = 2;
 */

//
//  Artwork.swift
//  Bagation
//
//  Created by vivek soni on 18/01/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class Artwork: NSObject, MKAnnotation  {
    let title: String?
    let locationName: String
    let discipline: String
    let detailDic: NSDictionary
    let coordinate: CLLocationCoordinate2D
    let bagSpace: String?
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D,detailDic: NSDictionary,bagSpace: String) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.detailDic = detailDic
        self.bagSpace = bagSpace
        super.init()
    }
    
    init?(json: NSDictionary) {
        // 1
       
        self.detailDic = json
        if (json ["StartTime"] as? String == "") {
            let time = String(format:"%@ - %@","00:00","00:00")
            self.title = String(format:"%@ (Time:%@)",(json ["StoreName"] as? String)!,time)
        } else {
            let time = String(format:"%@ - %@",(json ["StartTime"] as? String)!,(json ["EndTime"] as? String)!)
            self.title = String(format:"%@ (Time:%@)",(json ["StoreName"] as? String)!,time)
            
        }
        //json ["StoreName"] as? String ?? "No Title"  //json[16] as? String ?? "No Title"
        
        let spaceInteger = Int((json ["BagSpace"] as? String)!)
        self.bagSpace = json ["BagSpace"] as? String
        let bookedInteger = Int((json ["BagBooked"] as? String)!)
        var totalAvailable = NSNumber(value: spaceInteger! - bookedInteger!)
        if (totalAvailable.intValue <= 0) {
            totalAvailable = 0
        }
        var value = ""
        if (json ["IsOnline"] as? String) == "0"
        {
            value = "Status: INACTIVE"
        }
        else if (json ["IsOnline"] as? String) == "1"
        {
            value = "Status: ACTIVE"
        }
        var days = ""
        let dayValue = json ["AvailabilityDays"] as? String ?? ""
        let arr = dayValue.components(separatedBy: ",")
        for ind in 0..<arr.count
        {
            let a = arr[ind]
            print(a)
            if a == "1"
            {
                days = days + ",Mon"
            }
            if a == "2"
            {
                days = days + ",Tue"
            }
            if a == "3"
            {
                days = days + ",Wed"
            }
            if a == "4"
            {
                days = days + ",Thur"
            }
            if a == "5"
            {
                days = days + ",Fri"
            }
            if a == "6"
            {
                days = days + ",Sat"
            }
            if a == "7"
            {
                days = days + ",Sun"
            }
//            days = String(days.dropFirst())
            print(days)
            
        }
        days = String(days.dropFirst())
        let str = "$4.00/hour Storage: " + (json ["BagSpace"] as? String)! + "" + " Available  "  + "\(value)" + " Days: " + "\(days)"
        self.locationName = String(format:str)  //"$4.00/hour Storage: 10 Available" //json[12] as! String
        
        //totalAvailable.doubleValue
        //(json ["BagSpace"] as? String)!
        self.discipline = "Monument"
        // 2
        var strLat = json ["Latitude"] as! String
        var strLong = json ["Longitude"] as! String
        
        strLat = strLat.replacingOccurrences(of: "some(\"", with: "")
        strLat = strLat.replacingOccurrences(of: "\")", with: "")
        strLong = strLong.replacingOccurrences(of: "some(\"", with: "")
        strLong = strLong.replacingOccurrences(of: "\")", with: "")
        
        if let latitude = Double(strLat),
            let longitude = Double(strLong) {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
    }
    
    var markerTintColor: UIColor  {
        switch discipline {
        case "Monument":
            return .red
        case "Mural":
            return .cyan
        case "Plaque":
            return .blue
        case "Sculpture":
            return .purple
        default:
            return .green
        }
    }
    
    var subtitle: String? {
        return locationName
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
       // mapItem.phoneNumber = discipline
        return mapItem
    }
    
}

//
//  Utility.swift
//  PigeonShip
//
//  Created by Vivek on 21/09/1938 Saka.
//  Copyright ©PigeonShip Inc. All rights reserved.
//

import UIKit

class Utility: NSObject {
    // MARK: - Email Validation
    class func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    // MARK: - showHUD with message
    class func showHUD(msg:String){
        HUDManager.sharedInstance.showHud()
    }
   // MARK: - hide HUD
    class func hideHUD(){
        HUDManager.sharedInstance.hideHud()
    }
    
     // MARK: - show alert with block
    class func showAlertOnViewController(VC:UIViewController, title:String, message:String,  completion: @escaping (_ results: UIAlertAction) -> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: {
            })
            completion(action)
        }
        alert.addAction(action)
        
        VC.present(alert, animated: true) {
        }
    }
    
    // MARK: - get Day date Month From Date String
    class func getDateDetailFrom(strDate:String) -> String{
        if strDate.isEmpty{
            return ""
        }
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.timeZone = TimeZone(abbreviation: "UTC")
        
        if strDate.contains("."){
            dateFormatterGet.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        }else{
            dateFormatterGet.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'Z'"
        }
        
        var date = Date()
        date = dateFormatterGet.date(from: strDate)!
        dateFormatterGet.timeZone = TimeZone.current
        dateFormatterGet.dateFormat = "EEEE MMM d yyyy h-a"
        
        let strReturn:String = dateFormatterGet.string(from: date)
        
        return strReturn
    }
    
    // MARK: - Convert  String To date
    class func getDateFromString(strDate:String) -> Date {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.timeZone = TimeZone(abbreviation: "UTC")
        
        if strDate.contains("."){
            dateFormatterGet.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        }else{
            dateFormatterGet.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'Z'"
        }
        
        var date = Date()
        date = dateFormatterGet.date(from: strDate)!
        dateFormatterGet.timeZone = TimeZone.current
        
        let strReturn:String = dateFormatterGet.string(from: date)
        let dateReturn:Date = dateFormatterGet.date(from: strReturn)!
        
        return dateReturn
    }

    
    // MARK: - Convert  NSdictionary To String
    class func generateParam(dicParam:NSDictionary?)-> NSString?{
        var param:NSString=""
        if (dicParam==nil || dicParam?.count==0)
        {
            return param
        }
        for (key, value) in dicParam! {
            param = "\(param as String)\((key as! String) as String)=\((value as! NSString) )&" as NSString
        }
        return param.substring(to: param.length-1) as NSString?
    }
   class func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func isIphone4 () -> Bool {
         return (UIScreen.main.bounds.height == 480.0);
    }
    
    class func isIphone5 () -> Bool {
        return (UIScreen.main.bounds.width == 320.0);
    }
    
    class func isIphone6 () -> Bool {
        return (UIScreen.main.bounds.width == 375.0);
    }
    
    class func isIphone6Plus () -> Bool {
        return (UIScreen.main.bounds.width == 414.0);
    }
    
    class func randomStringWithLength (length : Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    class func convertToDictionary(text: String) -> NSDictionary? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
     }
    
    class func convertUTCToLocal(strDate:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-SSSS"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date = dateFormatter.date(from:strDate)// create   date from string
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "MMM d, yyyy - h:mm a"
        dateFormatter.timeZone = NSTimeZone.local
        let timeStamp = dateFormatter.string(from: date!)
        return timeStamp
    }
}

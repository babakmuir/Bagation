//
//  APIManager.swift
//  PigeonShip
//
//  Created by Vivek on 16/11/2917.
//  Copyright © Vivek Soni. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import AlamofireImage

class APIManager: NSObject {
    
    // MARK: - POST WithOut Header
    /*class func postRequestWith(strURL: String, Param: [String: Any], callback: ((_ result:NSDictionary?, Error?) -> Void)?) {
        let url = "\(Constants.baseURLLocal)\(strURL)"
        let fileUrl = NSURL(string: url)
        //let headers : HTTPHeaders = ["Content-Type" : "application/json"]
     
        var request = URLRequest(url:fileUrl as! URL )
        request.httpMethod = "POST"
       // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: Param)
        Alamofire.request(request)
            .responseJSON { response in
                // do whatever you want here
                switch response.result {
                case .success(let value):
                    print(value)
                    let dict:NSDictionary = value as! NSDictionary
                    callback?(dict, nil)
                    break
                case .failure(let error):
                    // TODO deal with error
                    print(error)
                    callback?(nil, error)
                    break
                }
        }
    }*/
    
    // MARK: - POST WithOut Header
    class func postRequestWith(strURL: String, Param: [String: Any], callback: ((_ result:NSDictionary?, Error?) -> Void)?) {
        let url = "https://connect.stripe.com/oauth/\(strURL)"
        print (url)
        
        //   let headers : HTTPHeaders = ["Content-Type" : "application/json"]
        Alamofire.request(url, method: .post, parameters: Param, encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                //  print(value)
                let dict:NSDictionary = value as! NSDictionary
                callback?(dict, nil)
                break
            case .failure(let error):
                // TODO deal with error
                print(error)
                callback?(nil, error)
                break
            }
        }
    }
    
    // MARK: - POST With Header
    class func postRequestWithHeader(strURL: String, Param: [String: Any], callback: ((_ result:NSDictionary?, Error?) -> Void)?) {
        
        //let headers : HTTPHeaders = ["Content-Type" : "application/json","Authorization":String(format:"%@",Constants.objDefault.value(forKey: Constants.key_UserToken) as! String )]
       // let url = "\(Constants.baseURLLocal)\(strURL)"
        let fileUrl = NSURL(string: strURL)
        var request = URLRequest(url:fileUrl! as URL )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.FCM_Server_Key, forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONSerialization.data(withJSONObject: Param)
        Alamofire.request(request)
            .responseJSON { response in
                // do whatever you want here
                switch response.result {
                case .success(let value):
                    print(value)
                    let dict:NSDictionary = value as! NSDictionary
                    callback?(dict, nil)
                    break
                case .failure(let error):
                    // TODO deal with error
                    print(error)
                    callback?(nil, error)
                    break
                }
        }
    }
    
    class func sendFCMPushNotification (token: String) {
        let jsonPayload = ["notification":
            [
                "body" : "You have new message",
                "title": "Bagation",
                "sound": "default",
                "click_action":"myAction"
            ],
                           "to":token,
                           "priority" : "high",
                           "content_available": true,
                        "mutable_content": true
            ]
            as [String : Any]
        
        APIManager.postRequestWithHeader(strURL: Constants.URL_SendNotification, Param: jsonPayload) { (dicdata, error) in
            print (dicdata ?? "")
            print (error ?? "")
        }
    }
    
    // MARK: - GET
    class func getRequestWith(strURL: String,Param: [String: Any], callback: ((_ result:NSDictionary?, Error?) -> Void)?) {
        var url:String = ""
        if strURL.contains("geocode") {
            url = "\(Constants.baseURLGoogle)\(strURL)"
        } else {
            url = "\(Constants.baseURLLocal)\(strURL)"
        }
        print(url)
        //let headers : HTTPHeaders = ["Content-Type" : "application/json"]
        
        print(Param)
        Alamofire.request(url, method: .get, parameters: Param, encoding: URLEncoding.default).responseString { response in
            switch response.result {
            case .success(let value):
                do {
                    
                    let data  = try JSONSerialization.jsonObject(with: value.data(using: .utf8)!, options: .allowFragments) as? Array<Dictionary<String, Any>>
                    
                    if data == nil  {
                        if let data = value.data(using: String.Encoding.utf8) {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                                
                                callback?(json as NSDictionary?, nil)

                            } catch {
                                print("Something went wrong")
                            }
                        }
                        
                    } else {
                        var dict : [String: AnyObject] = [:]
                        dict["detail"] = data as AnyObject?
                        callback?(dict as NSDictionary?, nil)
                    }
                    //let firstElement: Dictionary<String, Any> = data!.first!
                   // print("First dictionary element: \(firstElement)")
                   // print("Quantity from first dictionary element: \(firstElement["qty"] as! String)")
                    
                }
                catch{
                    print ("                                                                                                                                                        ")
                }
                
               
                break
              
            case .failure(let error):
                // TODO deal with error
                print(error)
                callback?(nil, error)
                break
            }
        }
    }
    
    static func checkOnlineStatus(BaghandlerID:Int, IsOnline:Int, SuccessHandler: @escaping(_ responce:JSON) -> Void)
    {
        var params = [String:Any]()
        params["BaghandlerID"] = BaghandlerID
        params["IsOnline"] = IsOnline
        

        ServiceManagerClass.requestWithGet(methodName: "SetStoreOnlineOffline?IsOnline=\(IsOnline)&BaghandlerID=\(BaghandlerID)", parameter: params) { (jsonResponse) in
            print(jsonResponse)

        }
    }
    
    static func setAvailability(BaghandlerID:Int, availability:String, SuccessHandler: @escaping(_ responce:JSON) -> Void)
    {
        var params = [String:Any]()
        params["BaghandlerID"] = BaghandlerID
        params["IsOnline"] = availability
        ServiceManagerClass.requestWithGet(methodName: "SetAvailability?BaghandlerID=\(BaghandlerID)&availability=\(availability)", parameter: params) { (jsonResponse) in
            print(jsonResponse)

        }
    }
    
    static func editBooking(OrderID:Int, StartDate:String,EndDate:String, SuccessHandler: @escaping(_ responce:JSON) -> Void)
    {
        var params = [String:Any]()
        params["OrderID"] = OrderID
        params["StartDate"] = StartDate
        params["EndDate"] = EndDate
        print(params)
        ServiceManagerClass.requestWithGet(methodName: "EditOrderDetailGet?OrderID=\(OrderID)&StartDate=\(StartDate)&EndDate=\(EndDate)", parameter: params) { (jsonResponse) in
            print(jsonResponse)
            
        }
    }
    
    static func deleteBooking(OrderID:Int, SuccessHandler: @escaping(_ responce:JSON) -> Void)
    {
        var params = [String:Any]()
        params["OrderID"] = OrderID
        ServiceManagerClass.requestWithGet(methodName: "DeleteOrderDetailGet?OrderID=\(OrderID)", parameter: params) { (jsonResponse) in
            print(jsonResponse)
            
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    
    
    // MARK: - Download Image From URL
    class func downloadImageFrom(strUrl:String, callback: ((_ image:UIImage?) -> Void)?) {
        if strUrl.isEmpty{
            return
        }
        let urlImg = URL(string: strUrl.replacingOccurrences(of: " ", with: "%20"))!
        let urlRequest = URLRequest(url: urlImg)
        //   let filter = AspectScaledToFillSizeCircleFilter(size: CGSize(width: 100.0, height: 100.0))
        ImageDownloader.default.download(urlRequest) { (data) in
            print("Downloaded Image: \(data)")
            switch data.result {
            case .success(let value):
                callback?(value)
                break
            case .failure(let error):
                // TODO deal with error
                print(error)
                callback?(nil)
                break
            }
        }
    }
   
   class func cancelAllAPIRequest(){
    Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
        sessionDataTask.forEach { $0.cancel() }
        uploadData.forEach { $0.cancel() }
        downloadData.forEach { $0.cancel() }
    }
   }
    
 /* class func sendPushNotification(brandId:String,roomType:String,conversationId:String,senderId:String, instanceIds:NSMutableArray, withTitle title:String, senderName sender:String, withMessage message:String) {
        let headers = [
            "Content-Type"  : "application/json",
            "Authorization" : Constants.FCM_Server_Key
        ]
        
        let jsonPayload = ["notification":
            [
                "body" : "\(sender): \(message)",
                "title": title,
                "sound": "default",
                "click_action":"myAction"
            ],
                           "data" : [
                            "brand_id" : brandId,
                            "room_type" : roomType,
                            "conversation_id" : conversationId,
                            "firebase_id":senderId
            ],
                           "registration_ids": instanceIds,
                           "priority" : "high",
                           "content_available": true
        ]
            as [String : Any]   
        
        //  print(jsonPayload)
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonPayload, options: JSONSerialization.WritingOptions.prettyPrinted)
    //NSURL(string:Constants.URL_SendNotification)!
    //.UseProtocolCachePolicy
        let request = NSMutableURLRequest(url: URL(string: Constants.URL_SendNotification)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData
    let session = URLSession(configuration: URLSessionConfiguration.default)
    print("THIS LINE IS PRINTED")
    let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
        if let data = data {
            print("THIS ONE IS PRINTED, TOO")
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                taskCallback(true, json as AnyObject?)
            } else {
                taskCallback(false, json as AnyObject?)
            }
        }
    })
    task.resume()
    
    
    
//        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
//            print (response)
//            instanceIds.removeAllObjects()
//        })
            //task.resume()
    }*/
    
    class func uploadImageWith(img:UIImage ,callback: ((_ result:NSDictionary?, Error?) -> Void)?){
        let data = UIImageJPEGRepresentation(img, 1.0)
        let url = "\(Constants.baseURLLocal)\(Constants.requestuploadUserPicture)"
        
        let strURl = String(format:"%@?UserID=%@",url,User.shared.userId)
        Alamofire.upload(multipartFormData: { (multipartData) in
            multipartData.append(data!, withName: "file", fileName: "file.jpeg", mimeType: "image/jpeg")
            
        }, to: strURl, encodingCompletion: { (SessionManager) in
            print(SessionManager)
            switch SessionManager {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let dict:NSDictionary = value as! NSDictionary
                        callback?(dict, nil)
                        break
                    case .failure(let error):
                        // TODO deal with error
                        print(error)
                        callback?(nil, error)
                        break
                    }
                    //                                    if let JSON = response.result.value {
                    //                                        print("JSON: \(JSON)")
                    //                                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        })
        
    }
    
}


extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}

//  ServiceManagerClass.swift
//  BrainCal
//
//  Created by Logictrix iOS3 on 24/07/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MBProgressHUD

class ServiceManagerClass: NSObject {
    
    static  let baseUrl =  "http://bagationservice-prod.ap-southeast-2.elasticbeanstalk.com/BagationService.svc/"
    
//    static  let baseUrl =  "http://demo.theweblogics.com/rinku/rento/api/api.php/"
    
//    static  let ImageUrl =  "http://www.rentopolous.com/api/"
    
    class func requestWithPost(methodName:String, parameter:[String:Any]?,Auth_header:[String:String], successHandler: @escaping(_ success:JSON) -> Void)
    {
        // CommonVC.showHUD()noyi
        let parameters: Parameters = parameter!
        var jsonResponse:JSON!
        var errorF:NSError!
        print(errorF)
        let urlString = baseUrl.appending("\(methodName)")
        print(urlString)
        print("parameters",parameters)
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        //"text/plain; charset=utf-8"
        //   URLRequest.setValue("application/json",
        //             forHTTPHeaderField: "Content-Type")
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        
        print("urlString",urlString)
        sessionManager.request(urlString, method: .post, parameters: parameters, encoding:URLEncoding.httpBody , headers: headers).responseJSON { (response:DataResponse<Any>) in
            switch response.result{
            case .failure(let error):
                print(error.localizedDescription)
                errorF = error as NSError
//                self.hideLoadingHUD()
                ServiceManagerClass.alert(message: error.localizedDescription)
                break
            case .success(let value):
                print("value",value)
                //                print("response.request",response.request!)  // original URL request
                //                print("response",response.response!) // HTTP URL response
                //   print("ggg",response.data!)     // server data
                //  print("result",response.result)   // result of response serialization
                
                do{
                    let json = JSON(data: response.data!)
                    print("json",json)
                    let jsonType = [json] as NSArray
                    print("jsonType",jsonType)
                    jsonResponse = json
                    break
                }
                catch{
                    print("error",error.localizedDescription)
                }
                
            }
            if jsonResponse !=  nil{
                successHandler(jsonResponse)
            }
                
                
            else{
                //     ServiceManagerClass.alert(message: errorF.localizedDescription)
            }
//             KRProgressHUD.dismiss()
//            SVProgressHUD.dismiss()
            sessionManager.session.invalidateAndCancel()
        }
    }
    
//    class func requestWithPostTest(methodName:String , parameter:[String:Any]?, successHandler: @escaping (_ success:JSON) -> Void) {
//        let errorDict:[String:Any] = [:]
//        var errorJson:JSON = JSON(errorDict)
//
//
//            // indicator.startAnimating()
//        let parameters: Parameters = parameter!
//            var jsonResponse:JSON!
//            let urlString = baseUrl.appending("\(methodName)")
////         let urlString = "http://demo.theweblogics.com/rinku/rento/api/api.php/v3/listings/post?title=testimony&GEO_formatted_address=A-4CBhawaniSinghRd_Jaipur_302001&GEO_lat=26.901101&GEO_lng=75.797033GEO_street_number=1&GEO_route=&GEO_neighbourhood=&GEO_locality=Jaipur&GEO_administrative_area_level_1=&GEO_country=India&GEO_postal_code=302001&GEO_location_type=ROOFTOP&description=Duijurur&propertyType=Condo&price=52242&bedrooms=2&bathrooms=1.5&furnished=true&pets=true&forRentBy=owner&smoking=true&postOptions=&expiryDate=&sessionId=g5Y8W33BqLBqMHFIrBImEHkPKmP2k98Ae7JbaMNBxo1k6&username=a&imageUrls=&cable=1&dishwasher=1&electricity=1&elevator=1&email=s@s.com&fenced=1&gym=1&heat=1&hideAddress=0&inSuiteLaundry=1&internet=1&parking=outdoor&phone=7665757276&pool=1&water=1&availability=2018-8-31"
//
//
//            Alamofire.request(urlString, method: .post, encoding: JSONEncoding.default).responseJSON { (response:DataResponse<Any>) in
//                switch response.result{
//                case .failure(let error):
//                    print(error)
//                    break
//                case .success(let value):
//                    print(value)
//                    print(response.request!)  // original URL request
//                    print(response.response!) // HTTP URL response
//                    print(String(data: response.data!, encoding: .utf8)!)     // server data
//                    print(response.result)   // result of response serialization
//
//                    let json = JSON(data: response.data!)
//                    print("\(json)")
//                    jsonResponse = json
//                    break
//                }
//                successHandler(jsonResponse)
//                // indicator.stopAnimating()
//            }
//
//
//
//    }
    
    
//    class func requestWithPostMultipart(sessionId:String , username:String, listingkey:String, image:UIImage, parameter:[String:Any]?, successHandler: @escaping (_ success:JSON) -> Void)
//    {
//        let parameters: Parameters = parameter!
//        var jsonResponse:JSON!
//
////        let urlString = ImageUrl.appending("\(sessionId)")+("\(username)")+("\(listingkey)")
////        let urlString = ImageUrl.appending("listings/images_app")+"?"+("sessionId=\(sessionId)")+"&"+("username=\(username)")+"&"+("listingKey=\(listingkey)")
////        print(urlString)
//
//        // let image = UIImage(named: "image.png")
//        Alamofire.upload(multipartFormData: { (multipartFormData) in
//            multipartFormData.append(UIImageJPEGRepresentation(image, 0.5)!, withName: "imageUrl[]", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
//            for (key, value) in parameters {
//                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
//            }
//        }, to: urlString, method: .post , headers:nil, encodingCompletion: { (result) in
//            switch result {
//            case .success(let upload,_,_):
//
//                upload.uploadProgress(closure: { (progress) in
//                    print(progress.fractionCompleted * 100)
//                })
//
//                upload.responseJSON(completionHandler: { (response) in
//                    let json = JSON(data: response.data!)
//                    print("\(json)")
//                    jsonResponse = json
//                    //   indicator.stopAnimating()
//                    successHandler(jsonResponse)
//                })
//            case .failure(let error):
//                print(error)
//
//            }
//        })
//        //        }
//        //        else
//        //        {
//        //            ServiceManager.alert(message: "Network is Unreachable")
//        //        }
//    }

        class func requestWithGet(methodName:String , parameter:[String:Any]?, successHandler: @escaping (_ success:JSON) -> Void) {
    
                var jsonResponse:JSON!
                let urlString = baseUrl.appending("\(methodName)")
                print(urlString)
    
                Alamofire.request(urlString, method: .get, parameters:[:], encoding: URLEncoding.default).responseJSON { (response:DataResponse<Any>) in
                    switch response.result{
                    case .failure(let error):
                        print(error)
                        //  errorJson = ["status":"Failed","message":error.localizedDescription]
                        // SVProgressHUD.dismiss()
                        // successHandler(errorJson)
                        ServiceManagerClass.alert(message: error.localizedDescription)
                        break
                    case .success(let value):
                        print(value)
                        print(response.request!)  // original URL request
                        print(response.response!) // HTTP URL response
                        print(response.data!)     // server data
                        print(response.result)   // result of response serialization
    
                        let json = JSON(data: response.data!)
                        print("\(json)")
                        jsonResponse = json
                        successHandler(jsonResponse)
                        break
                    }
//                    SVProgressHUD.dismiss()
            }
    //        else
    //        {
    //            errorJson = ["status":0,"message":"Network is Unreachable"]
    //            successHandler(errorJson)
    //            ServiceManagerClass.alert(message: "Network is Unreachable")
    //        }
        }
    
//
//    class func requestWithPostMultipartImage(methodName:String , image:UIImage, parameter:[String:Any]?, successHandler: @escaping (_ success:JSON) -> Void) {
//
//
//            // indicator.startAnimating()
//            let parameters: Parameters = parameter!
//            var jsonResponse:JSON!
//            let urlString = ImageUrl.appending("\(methodName)")
//            print(urlString)
//
//            let header: HTTPHeaders = ["Content-Type":"multipart/form-data"]
//            print(header)
//
//            //photo_path                // let image = UIImage(named: "image.png")
//            Alamofire.upload(multipartFormData: { (multipartFormData) in
//                multipartFormData.append(UIImageJPEGRepresentation(image, 0.5)!, withName: "imageUrl[]", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
//                //multipartFormData.append(video, withName: "video", fileName: "video.mov", mimeType: "video/mp4")
//                for (key, value) in parameters {
//                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
//                }
//            }, to: urlString, method: .post , headers: header, encodingCompletion: { (result) in
//                switch result {
//                case .success(let upload, _, _):
//
//                    upload.uploadProgress(closure: { (progress) in
//                        print(progress.fractionCompleted * 100)
//                    })
//
//                    upload.responseJSON(completionHandler: { (response) in
//                        let json = JSON(data: response.data!)
//                        print("\(json)")
//                        jsonResponse = json
//                        //   indicator.stopAnimating()
//                        successHandler(jsonResponse)
//                    })
//                case .failure(let error):
//                    print(error)
//
//
//                }
//            })
//
//    }
    
    
    
    
    
    
    
    
    
    
    

    class func topMostController() -> UIViewController
    {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil)
        {
            topController = topController?.presentedViewController
        }
        return topController!
    }

    class func alert(message:String)
    {
        let alert=UIAlertController(title: "Rentopolous", message: message, preferredStyle: .alert);
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel) { action -> Void in
        }
        alert.addAction(cancelAction)
        
        print(ServiceManagerClass.topMostController())
        ServiceManagerClass.topMostController().present(alert, animated: true, completion: nil);
    }

    class func UserDetials() -> NSDictionary
    {
        guard let data = UserDefaults.standard.value(forKey: "LoginUserData") else {
            return [:]
        }
        guard let dict:NSDictionary = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NSDictionary else {
            return [:]
        }
        print(dict as Any)
        
        return dict
    }
    
}

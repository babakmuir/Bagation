//
//  FireBaseManager.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import Foundation

enum messageType:String {
    case image = "1"
    case text = "2"
}

class FireBaseManager: NSObject {
    
    var storageRef: StorageReference!
    var dataBase: DatabaseReference!
    let password = "123456"
    let inbox = "inbox"
    let messages = "messages"
    let images = "images"

    class var sharedInstance: FireBaseManager {
        struct Static {
            static let instance: FireBaseManager = FireBaseManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        storageRef = Storage.storage().reference()
        dataBase = Database.database().reference()
    }
    
    func getCurrentUser() -> String {
        let strID:String  = (Auth.auth().currentUser?.uid)!
        return strID
    }
    
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" //Your date format
        dateFormatter.timeZone = TimeZone.current //Current time zone
        let newDate = dateFormatter.string(from: Date()) //pass Date here
        return newDate
    }
    
    // User Authentication
    
    func signupUser(email:String){
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
            }else {
                print(authResult?.user.email ?? "")
                self.insertUserFirebaseDetail()
            }
        }
    }
    
    func loginUser(email:String,callback: ((_ isSuccess:Bool?, _ errorMessage:String?) -> Void)?){
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                callback!(false,error?.localizedDescription)
            }else {
                print(authResult?.user.email ?? "")
                self.insertUserFirebaseDetail()
                callback!(true,"")
            }
        }
    }
    
    func insertUserFirebaseDetail(){
        if Auth.auth().currentUser != nil {
            let strID:String  = (Auth.auth().currentUser?.uid)!
            let  param = ["UserID":User.shared.userId,"FirebaseID":strID] as [String : Any]
            print(param)
            
            APIManager.getRequestWith(strURL: Constants.firebaseUserAPI, Param: param) { (Dict, Error) in
                self.insertUserImage()
                if Error == nil {
                    //print(Dict)
                }
            }
        }
    }
    
    func insertUserImage(){
        if Auth.auth().currentUser != nil {
            let strID:String  = (Auth.auth().currentUser?.uid)!
            if User.shared.userType == "1" {
                let dict = ["image":User.shared.imagepath,"name":User.shared.fullname,"firebase_id":strID,"deviceToken":User.shared.token,"isOnline":"true"]
                self.dataBase.child(images).child(strID).updateChildValues(dict)
            }else {
                let dict = ["image":User.shared.imagepath,"name":User.shared.StoreName,"firebase_id":strID,"deviceToken":User.shared.token,"isOnline":"true"]
                self.dataBase.child(images).child(strID).updateChildValues(dict)
            }
        }
    }
    
    func logoutUser(){
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func getInboxList(callback: ((_ Results:[Inbox]?, _ errorMessage:String?) -> Void)?){
        if Auth.auth().currentUser != nil {
            let strID:String  = (Auth.auth().currentUser?.uid)!
            var objects = [Inbox]()
            self.dataBase.child(inbox).observe(.value, with: { (snapshot) in
                
                if snapshot.exists() {
                    let array:[Any] = snapshot.children.allObjects
                    objects.removeAll()
                    for obj in array {
                        let appeal = Inbox(inboxDict: (obj as! DataSnapshot).value as! [String : Any])
                        var userID:String = ""
                        if appeal.userID != strID  {
                            userID = appeal.userID
                        }else {
                            userID = appeal.receiverID
                        }
                        
                        if (userID != "") {
                            let refrence = self.dataBase.child(self.images).child(userID)
                            refrence.observe(.value, with: { (snapShot) in
                                if snapShot.exists(){
                                    let array:[String:Any] = snapShot.value as! [String : Any]
                                    print(array)
                                    if array.count != 0 {
                                        let fire = FirebaseInfo(dict:array)
                                        if appeal.userID == strID || appeal.receiverID == strID {
                                            appeal.receiverName = fire.name
                                            appeal.receiverPic = fire.image
                                            appeal.receiverDeviceToken = fire.deviceToken
                                            appeal.receiverOnlineStatus = fire.onlineStatus
                                            objects.append(appeal)
                                        }
                                        callback!(objects,"")
                                    }
                                }
                            })
                        }
                    }
                }else {
                    callback!(objects,"No Results Found")
                }
            })
        }
    }
    
    func getChatList(callback: ((_ Results:[Chat]?, _ errorMessage:String?) -> Void)?){
        if Auth.auth().currentUser != nil {
            let strID:String  = (Auth.auth().currentUser?.uid)!
            var objects = [Chat]()
            self.dataBase.child(messages).queryOrdered(byChild: "user_id").queryEqual(toValue: strID).observe(.value, with: { (snapshot) in
                
                if snapshot.exists() {
                    let array:[Any] = snapshot.children.allObjects
                    for obj in array {
                        let appeal = Chat(chatDict: (obj as! DataSnapshot).value as! [String : Any])
                        objects.append(appeal)
                    }
                    callback!(objects,"")
                }else {
                    callback!(objects,"No Results Found")
                }
            })
            
        }
        
    }
    
    func sendMessage(text:String, toUser:String,toID:String,mediaType:messageType,callback: ((_ isSuccess:Bool?, _ errorMessage:String?) -> Void)?) {
        
        if Auth.auth().currentUser != nil {
            let strID:String  = (Auth.auth().currentUser?.uid)!
            var key:String! = ""
            if User.shared.userType == "1" {
                key = Checksum.md5Hash(of: toID + strID)
            }else {
                key = Checksum.md5Hash(of: strID + toID)
            }
            let refrence = self.dataBase.child(messages).child(key!).childByAutoId()
            let messageDict:[String:Any] = [ "text"    : text ,
                                            "receiver_name" : toUser,
                                            "receiver_id" : toID,
                                            "user_id" : strID,
                                            "sender_name":User.shared.fullname,
                                            "date":getCurrentDate(),
                                            "mediaType":mediaType.rawValue] as [String : Any]
            refrence.updateChildValues(messageDict, withCompletionBlock: { (error, Reference) in
                if let error = error {
                    callback!(false,error.localizedDescription)
                }else{
                    
                    self.lastMessage(nodeID: key!, text: text, toUser: toUser, toID: toID, isSeen: false)
                    callback!(true,"")
                }
            })
        }else {
            callback!(false,"User Not logged In.")
        }
    }
 
    func lastMessage(nodeID:String,text:String, toUser:String,toID:String,isSeen:Bool) {
        
        if Auth.auth().currentUser != nil {
            let strID:String  = (Auth.auth().currentUser?.uid)!
            let refrence = self.dataBase.child(inbox).child(nodeID)
            let messageDict:[String:Any] = [ "text"    : text ,
                                             "receiver_name" : toUser,
                                             "receiver_id" : toID,
                                             "user_id" : strID,
                                             "sender_name":User.shared.fullname,
                                             "isSeen":isSeen,
                                              "date":getCurrentDate()] as [String : Any]
            refrence.updateChildValues(messageDict, withCompletionBlock: { (error, Reference) in
                if let error = error {
                    print(error.localizedDescription)
                }else{
                    
                }
            })
        }
    }
    func updateImageForLastMessage(toID:String){
        
        if Auth.auth().currentUser != nil {
            let strID:String  = (Auth.auth().currentUser?.uid)!
            var key:String! = ""
            if User.shared.userType == "1" {
                key = Checksum.md5Hash(of: toID + strID)
            }else {
                key = Checksum.md5Hash(of: strID + toID)
            }
            let refrence = self.dataBase.child(images).child(toID)
            refrence.observe(.value, with: { (snapShot) in
                if snapShot.exists(){
                    let array:[String:Any] = snapShot.value as! [String : Any]
                    print(array)
                    if array.count != 0 {
                        let fire = FirebaseInfo(dict:array)
                        let refrence2 = self.dataBase.child(self.inbox).child(key!)
                     let messageDict:[String:Any] = [ "receiver_pic"    : fire.image ] as [String : Any]
                        refrence2.updateChildValues(messageDict)
                    }
                }
            })
        }
    }
    
    func updateChatStatusForUser(statusValue:String) {
        
        if Auth.auth().currentUser != nil {
            let strID:String  = (Auth.auth().currentUser?.uid)!
            let dict = ["image":User.shared.imagepath,"name":User.shared.fullname,"firebase_id":strID,"deviceToken":User.shared.token,"isOnline":statusValue]
            self.dataBase.child(images).child(strID).updateChildValues(dict)
        }
    }
    
    func getMessages(toID:String,callback: ((_ message:Chat?, _ errorMessage:String?) -> Void)?){
        if Auth.auth().currentUser != nil {
            let strID:String  = (Auth.auth().currentUser?.uid)!
            var key:String! = ""
            if User.shared.userType == "1" {
                key = Checksum.md5Hash(of: toID + strID)
            }else {
                key = Checksum.md5Hash(of: strID + toID)
            }
            print(key)
            let refrence = self.dataBase.child(messages).child(key!)
            refrence.observe(DataEventType.childAdded, with: { (snapShot) in
                if snapShot.exists(){
                    let message =  Chat(chatDict: snapShot.value as! [String : Any])
                    callback!(message,"")
                }else {
                    callback!(nil,"no Message")
                }
            })
        }
    }
    
    func uploadImage(image:UIImage,callback: ((_ imgUrl:String?, _ errorMessage:String?) -> Void)?) {
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.8)!
        // set upload path
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        self.storageRef.child(images).putData(data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                callback!(nil,error.localizedDescription)
            } else {
                //store downloadURL
                //let downloadURL = metaData!.downloadURL()!.absoluteString
                //callback!(downloadURL,nil)
                
                self.storageRef.downloadURL{ url, error in
                    if let error = error {
                        print(error)
                    } else {
                        callback!(url?.absoluteString, nil)
                    }
                }
            }
        }
    }
    
}
